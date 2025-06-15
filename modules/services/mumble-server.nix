{
  services.murmur = {
    enable = true;
    openFirewall = true;
    allowHtml = true;
    bandwidth = 128000;
    clientCertRequired = true;
    welcometext = "Welcome to OpenIt2";
    users = 10;
    imgMsgLength = 0;
    registerName = "OpenIt2";
  };

  networking.firewall.interfaces = {
    wg-discord.allowedUDPPorts = [ 64738 ];
    wg-discord.allowedTCPPorts = [ 64738 ];
  };

  custom.services.caddy.virtualHosts."murmur.494203.xyz".extraConfig = ''
    reverse_proxy localhost:64738
  '';
}
