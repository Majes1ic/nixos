{
  config,
  pkgs,
  lib,
  ...
}:
let
  porkBunPatchedCaddy =
    (pkgs.caddy.overrideAttrs (old: {
      vendorHash = "sha256-1OJelf2Ui7Iz4SoXStfTwEtLi/fSpgfR2gqsZi7KBZE=";
      preBuild = ''
        chmod -R u+w vendor
        [ -f vendor/go.mod ] && mv -t . vendor/go.{mod,sum}
        go generate
        sed -i "/standard/a _ \"github.com/caddy-dns/porkbun\"" ./cmd/caddy/main.go
      '';
    })).override
      {
        buildGoModule =
          args:
          pkgs.buildGoModule (
            args
            // {
              modBuildPhase = ''
                ${lib.getExe pkgs.gnused} -i "/standard/a     _ \"github.com/caddy-dns/porkbun\"" ./cmd/caddy/main.go
                cat ./cmd/caddy/main.go
                go get github.com/caddy-dns/porkbun@v0.2.1
                go generate
                go mod vendor
              '';

              modInstallPhase = ''
                mv -t vendor go.mod go.sum
                cp -r vendor $out
              '';
            }
          );
      };
in
{
  services.caddy = {
    enable = true;
    package = porkBunPatchedCaddy;

    # Note from Josh: Double check that the porkbun vars in your secrets file
    # match these exactly (the two below are correct now but I initially gave
    # you the wrong ones)
    globalConfig = ''
      acme_dns porkbun {
        api_key {env.PORKBUN_API_KEY}
        api_secret_key {env.PORKBUN_SECRET_API_KEY}
      }
    '';

    virtualHosts."torrent.494203.xyz".extraConfig = ''
      reverse_proxy http://localhost:7337
    '';
  };

  age.secrets.porkbunVars.file = ../../secrets/porkbunVars.age;
  systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.porkbunVars.path;

  virtualisation.vmVariant = {
    services.caddy = {
      # Confusingly auto_https off doesn't actually server all hosts of http
      # Each virtualhost needs to explicity specify http://
      # https://caddy.community/t/making-sense-of-auto-https-and-why-disabling-it-still-serves-https-instead-of-http/9761
      globalConfig = lib.mkVMOverride ''
        debug
        auto_https off
      '';

      virtualHosts = lib.mkVMOverride (
        lib.mapAttrs (
          _: value: value // { hostName = ("http://" + value.hostName); }
        ) config.services.caddy.virtualHosts
      );
    };
  };
}
