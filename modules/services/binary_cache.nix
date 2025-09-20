{
  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/cache-priv-key.pem";
  };

  networking.firewall.interfaces = {
    wg-discord.allowedUDPPorts = [ 5000 ];
    wg-discord.allowedTCPPorts = [ 5000 ];
  };

  custom.services.caddy.virtualHosts."http://binarycache.494203.xyz".extraConfig = ''
    reverse_proxy localhost:5000
  '';
}
