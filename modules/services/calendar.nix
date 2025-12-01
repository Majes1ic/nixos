{
  services.radicale = {
    enable = true;
    settings = {
      server = {
        hosts = [ "0.0.0.0:5232" ];
      };
      auth = {
        type = "none";
      };
    };
  };

  custom.services.caddy.virtualHosts."calendar.494203.xyz".extraConfig = ''
    reverse_proxy localhost:5232
  '';

  networking.firewall.interfaces."wg-discord".allowedUDPPorts = [ 5232 ];
  networking.firewall.interfaces."wg-discord".allowedTCPPorts = [
    5232
  ];
}
