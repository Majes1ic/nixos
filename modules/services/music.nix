{ config, ... }:
let
  http_port = 5030;
  soul_port = 50350;
in
{
  services.slskd = {
    enable = true;
    settings.soulseek.listen_port = soul_port;
    domain = null;
  };

  systemd.services.slskd.vpnConfinement = {
    vpnNamespace = "air-vpn";
    enable = true;
  };

  vpnNamespaces.air-vpn = {
    portMappings = [
      {
        from = http_port;
        to = http_port;
      }
    ];
    openVPNPorts = [
      {
        #public port for VPN can configure on air-vpn site
        port = soul_port;
        protocol = "both";
      }
    ];
  };

  custom.services.caddy.virtualHosts."music.494203.xyz".extraConfig = ''
    reverse_proxy http://${config.vpnNamespaces.air-vpn.namespaceAddress}:${toString http_port}
  '';
}
