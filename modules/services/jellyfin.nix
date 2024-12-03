{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  custom.services.caddy.virtualHosts."jellyfin.494203.xyz".extraConfig = ''
    reverse_proxy http://localhost:8096
  '';
}
