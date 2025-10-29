{
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  custom.services.caddy.virtualHosts."jellyseerr.494203.xyz".extraConfig = ''
    reverse_proxy localhost:5055
  '';
}
