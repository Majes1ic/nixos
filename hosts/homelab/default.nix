{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core

    ../../modules/hardware/nvidia.nix
    ../../modules/hardware/networking.nix

    ../../modules/system/firewall.nix
    ../../modules/system/virtualisation.nix
    ../../modules/system/ssh.nix

    ../../modules/services/caddy.nix
    ../../modules/services/jellyfin.nix
    ../../modules/services/immich.nix
    ../../modules/services/qbittorrent-nox.nix
    ../../modules/services/air-vpn.nix
    ../../modules/services/file-server.nix
    ../../modules/services/calibre.nix
    ../../modules/services/dashy.nix
    ../../modules/services/coop_minesweeper.nix
    ../../modules/services/mumble-server.nix
    ../../modules/services/monitoring.nix
    ../../modules/services/unifi.nix
    #../../modules/services/music.nix
    #    ../../modules/services/matrix.nix
    #    ../../modules/services/teamspeak3.nix
  ];

  networking.hostId = "d48f462c";
  networking.firewall.defaultInterfaces = [ "enp34s0" ];
  system.stateVersion = "23.05";
}
