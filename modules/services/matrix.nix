{
  #  services.matrix-synapse = {
  #    enable = true;
  #    settings.server_name = "494203.xyz";
  #    settings.public_baseurl = "https://matrix.494203.xyz";
  #    settings.listeners = [
  #      {
  #        bind_addresses = [
  #          "127.0.0.1"
  #        ];
  #        port = 8008;
  #        resources = [
  #          {
  #            compress = true;
  #            names = [
  #              "client"
  #            ];
  #          }
  #          #          {
  #          #            compress = false;
  #          #            names = [
  #          #              "federation"
  #          #            ];
  #          #          }
  #        ];
  #        tls = false;
  #        type = "http";
  #        x_forwarded = true;
  #      }
  #    ];
  #  };

  custom.services.caddy.virtualHosts."matrix.494203.xyz".extraConfig = ''
    reverse_proxy http://localhost:8008
  '';

  networking.firewall.interfaces."wg-discord".allowedUDPPorts = [ 8008 ];
  networking.firewall.interfaces."wg-discord".allowedTCPPorts = [
    8008
  ];
}
