{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.jellyfin.serviceConfig.supplementaryGroups = [ "media" ];

  custom.services.caddy.virtualHosts."jellyfin.494203.xyz".extraConfig = ''
    reverse_proxy http://localhost:8096
  '';
}
