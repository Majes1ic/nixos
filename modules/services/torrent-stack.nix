{
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };
  custom.services.caddy.virtualHosts."jellyseerr.494203.xyz".extraConfig = ''
    reverse_proxy localhost:5055
  '';

  services.radarr = {
    enable = true;
    openFirewall = true;
  };
  custom.services.caddy.virtualHosts."radarr.494203.xyz".extraConfig = ''
    reverse_proxy localhost:7878
  '';

  services.sonarr = {
    enable = true;
    openFirewall = true;
  };
  custom.services.caddy.virtualHosts."sonarr.494203.xyz".extraConfig = ''
    reverse_proxy localhost:8989
  '';

  services.bazarr = {
    enable = true;
    openFirewall = true;
  };
  custom.services.caddy.virtualHosts."bazarr.494203.xyz".extraConfig = ''
    reverse_proxy localhost:6767
  '';
}
