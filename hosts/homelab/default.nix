{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core

    ../../modules/hardware/nvidia1060.nix
    ../../modules/hardware/networking.nix

    ../../modules/system/firewall.nix
    ../../modules/system/virtualisation.nix
    (lib.modules.importApply ../../modules/system/ssh.nix { desktop = false; })

    #../../modules/services/backup.nix
    ../../modules/services/caddy.nix
    ../../modules/services/jellyfin.nix
    ../../modules/services/immich.nix
    ../../modules/services/qbittorrent-nox.nix
    ../../modules/services/air-vpn.nix
    ../../modules/services/file-server.nix
    ../../modules/services/calibre.nix
    ../../modules/services/coop_minesweeper.nix
    ../../modules/services/mumble-server.nix
    ../../modules/services/monitoring.nix
    ../../modules/services/unifi.nix
    ../../modules/services/binary_cache.nix
    ../../modules/services/memos.nix
    ../../modules/services/minecraftserver.nix
    ../../modules/services/uptime-kuma.nix
    ../../modules/services/torrent-stack.nix
    ../../modules/services/matrix-tuwunel.nix
    ../../modules/services/home-assistant.nix
    ../../modules/services/calendar.nix
    ../../modules/services/trilium.nix
    #../../modules/services/music.nix
    #../../modules/services/matrix.nix
    #../../modules/services/teamspeak3.nix
    #../../modules/services/dashy.nix
  ];

  networking.hostId = "d48f462c";
  networking.firewall.defaultInterfaces = [ "enp34s0" ];
  system.stateVersion = "23.05";
}
