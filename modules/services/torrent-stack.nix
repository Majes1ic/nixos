# need to configure port forwarding
{
  username,
  config,
  ...
}:
let
  mediaDir = "/data/media";
  vpnNamespace = "air-vpn";
  ports = {
    jellyseer = 5055;
    bazarr = 6767;
    radarr = 7878;
    sonarr = 8989;
    prowlarr = 9696;
  };
in
{
  #request manager
  services.jellyseerr = {
    enable = true;
  };
  systemd.services.jellyseerr.serviceConfig.supplementaryGroups = [ "media" ];
  custom.services.caddy.virtualHosts."jellyseerr.494203.xyz".extraConfig = ''
    reverse_proxy localhost:${toString ports.jellyseer}";
  '';

  #collection manager
  services.radarr = {
    enable = true;
    openFirewall = true;
  };
  systemd.services.radarr.serviceConfig.supplementaryGroups = [ "media" ];
  custom.services.caddy.virtualHosts."radarr.494203.xyz".extraConfig = ''
    reverse_proxy localhost:${toString ports.radarr}";
  '';

  #torrent finder
  services.sonarr = {
    enable = true;
  };
  custom.services.caddy.virtualHosts."sonarr.494203.xyz".extraConfig = ''
    reverse_proxy localhost:${toString ports.sonarr}";
  '';
  systemd.services.sonarr.serviceConfig.supplementaryGroups = [ "media" ];

  #torrent manager
  services.prowlarr = {
    enable = true;
  };

  systemd.services.prowlarr = {
    serviceConfig.supplementaryGroups = [ "media" ];
    vpnConfinement = {
      enable = true;
      inherit vpnNamespace;
    };
  };

  # open prowlarr port from vpn network namespace
  vpnNamespaces."air-vpn".portMappings = [
    {
      from = ports.prowlarr;
      to = ports.prowlarr;
    }
  ];

  custom.services.caddy.virtualHosts."prowlarr.494203.xyz".extraConfig = ''
    reverse_proxy ${config.vpnNamespaces."air-vpn".namespaceAddress}:${toString ports.prowlarr}";
  '';

  #subtitle manager
  services.bazarr = {
    enable = true;
  };
  systemd.services.bazarr.serviceConfig.supplementaryGroups = [ "media" ];
  custom.services.caddy.virtualHosts."bazarr.494203.xyz".extraConfig = ''
    reverse_proxy localhost:${toString ports.bazarr}";
  '';

  users.groups.media = { };
  users.users.${username}.extraGroups = [ "media" ];

  systemd.tmpfiles.rules = [
    "d ${mediaDir} 0770 root media - -"
    # Torrents are downloaded and seeded here. They are hardlinked by the
    # relevant arr service to a media dir.
    "d ${mediaDir}/torrents 0775 root media - -"
    "d ${mediaDir}/torrents/movies 0775 qbittorrent-nox qbittorrent-nox - -"
    "d ${mediaDir}/torrents/shows 0775 qbittorrent-nox qbittorrent-nox - -"
    "d ${mediaDir}/torrents/music 0775 qbittorrent-nox qbittorrent-nox - -"
    "d ${mediaDir}/movies 0775 root media - -"
    "d ${mediaDir}/shows 0775 root media - -"
    "d ${mediaDir}/books 0775 root media - -"
    "d ${mediaDir}/music 0775 root media - -"
  ];

  networking.firewall.interfaces."${vpnNamespace}-br".allowedTCPPorts = [
    ports.radarr
  ];
}
