{
  services.matrix-tuwunel = {
    enable = true;
    settings = {
      global = {
        server_name = "matrix.494203.xyz";
        allow_registration = true;
        registration_token = "BglbbPiAnUeS8rOh8ag83EtS0772";
      };
    };
  };
  custom.services.caddy.virtualHosts."matrix.494203.xyz".extraConfig = ''
    reverse_proxy localhost:6167
  '';

  networking.firewall.interfaces."wg-discord".allowedUDPPorts = [ 6167 ];
  networking.firewall.interfaces."wg-discord".allowedTCPPorts = [
    6167
  ];
}
