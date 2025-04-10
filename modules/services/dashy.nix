{ config, ... }:
let
  settings = {
    pageInfo = {
      title = "My Homelab";
      description = "For Harry";
    };
    appConfig = {
      theme = "nord-frost";
      layout = "auto";
      iconSize = "medium";
      language = "en-GB";
      statusCheck = true;
      hideComponents.hideSettings = false;
    };
    sections = [
      # !!!!!!!!!!!!!!!!!!!!!!!
      # You mush disable adblock browser
      # !!!!!!!!!!!!!!!!!!!!!!!
      {
        name = "Monitoring";
        icon = "fas fa-monitor-heart-rate";
        items = [
          {
            title = "Library";
            url = "https://books.494203.xyz";
            icon = "hl-uptime-kuma";
          }
          {
            title = "Jellyfin";
            url = "https://jellyfin.494203.xyz";
            icon = "hl-uptime-kuma";
          }
          {
            title = "Torrents";
            url = "https://torrent.494203.xyz";
            icon = "hl-uptime-kuma";
          }
          {
            title = "Files";
            url = "https://files.494203.xyz";
            icon = "hl-uptime-kuma";
          }
        ];
      }
      {
        name = "Tools";
        icon = "fas fa-rocket";
        items = [
          {
            title = "mikrotik Livingroom";
            url = "http://192.168.88.1";
            icon = "hl-mikrotik";
          }
        ];
      }
      {
        name = "Website";
        icon = "fas fa-bookmark";
        items = [
          {
            title = "Nix packages/Options";
            url = "https://search.nixos.org/packages";
            icon = "favicon";
          }
        ];
      }
    ];
  };
in
{

  services.dashy = {
    inherit settings;
    enable = true;
  };

  custom.services.caddy.virtualHosts."home.494203.xyz".extraConfig = ''
    root ${config.services.dashy.finalDrv}
    file_server
  '';

  networking.firewall.allowedUDPPorts = [ 8080 ];
  networking.firewall.allowedTCPPorts = [ 8080 ];

}
