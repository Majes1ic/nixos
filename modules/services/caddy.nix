{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkOption mapAttrs types;
  cfg = config.custom.services.caddy;
in
{
  options.custom.services.caddy = {
    virtualHosts = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Wrapper for Caddy virtual host config that configures DNS ACME for each
        endpoint
      '';
    };
  };

  config = {
    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/porkbun@v0.2.1" ];
        hash = "sha256-X8QbRc2ahW1B5niV8i3sbfpe1OPYoaQ4LwbfeaWvfjg=";
      };
      virtualHosts = mapAttrs (
        _: virtualHost:
        virtualHost
        // {
          extraConfig = ''
            tls {
              dns porkbun {
                api_key {env.PORKBUN_API_KEY}
                api_secret_key {env.PORKBUN_SECRET_API_KEY}
              }
              resolvers 1.1.1.1
            }
            ${virtualHost.extraConfig}
          '';
        }
      ) cfg.virtualHosts;
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
    networking.firewall.allowedUDPPorts = [ 443 ];
    networking.firewall.allowedTCPPorts = [
      443
      80
    ];

    # open ports on friends wg interface
    networking.firewall.interfaces."wg-discord".allowedUDPPorts = [ 443 ];
    networking.firewall.interfaces."wg-discord".allowedTCPPorts = [
      443
      80
    ];
  };
}
