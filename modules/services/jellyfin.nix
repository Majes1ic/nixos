{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  users.users.jellyfin = {
    extraGroups = [
      "media"
      "qbittorrent-nox"
    ];
  };

  systemd.services.jellyfin.serviceConfig.SupplementaryGroups = [
    "media"
    "qbittorrent-nox"
  ];

  custom.services.caddy.virtualHosts."jellyfin.494203.xyz".extraConfig = ''
    reverse_proxy localhost:8096
  '';
}
