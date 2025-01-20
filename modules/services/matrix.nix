{
  lib,
  ...
}:
{
  services.matrix-synapse = {
    enable = true;
    settings.server_name = "494203.xyz";
    settings.public_baseurl = "https://matrix.494203.xyz";
    settings.registration_shared_secret = "XH3a9rEE1N6rgUw!K0J89#3Jzy96";
    #settings.enable_registration = true;
    enableRegistrationScript = true;
    settings.listeners = [
      {
        bind_addresses = [
          "127.0.0.1"
        ];
        port = 8008;
        resources = [
          {
            compress = true;
            names = [
              "client"
            ];
          }
          {
            compress = false;
            names = [
              "federation"
            ];
          }
        ];
        tls = false;
        type = "http";
        x_forwarded = true;
      }
    ];
  };

  systemd.services.postgresql = {
    postStart = lib.mkAfter ''
      $PSQL -tAc "SELECT 1 FROM pg_database WHERE datname = 'matrix-synapse'" | grep -q 1 ||
        $PSQL -tAc 'CREATE DATABASE "matrix-synapse" TEMPLATE template0 LC_COLLATE = "C" LC_CTYPE = "C"'
      $PSQL -tAc 'GRANT ALL PRIVILEGES ON DATABASE "matrix-synapse" TO "matrix-synapse"'
    '';
  };
  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = "matrix-synapse";
        # ensureDBOwnership = true;
      }
    ];
  };

  custom.services.caddy.virtualHosts."matrix.494203.xyz".extraConfig = ''
    reverse_proxy http://localhost:8008
  '';

  networking.firewall.interfaces."wg-discord".allowedUDPPorts = [ 8008 ];
  networking.firewall.interfaces."wg-discord".allowedTCPPorts = [
    8008
  ];
}
