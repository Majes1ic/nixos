{
  services.calibre-web = {
    enable = true;
    listen.port = 9088;
    options = {
      enableBookUploading = true;
      enableBookConversion = true;
    };
  };

  networking.firewall.interfaces."enp3s0".allowedTCPPorts = [ 9088 ];
  networking.firewall.interfaces."wg-discord".allowedTCPPorts = [ 9088 ];
}
