{
  imports = [
    ./hardware-configuration.nix
    ../../modules/hardware/nvidia.nix
    ../../modules/core
    ../../modules/hardware/networking.nix
    ../../modules/system/firewall.nix
    ../../modules/system/virtualisation.nix
    ../../modules/services/caddy.nix
    ../../modules/services/jellyfin.nix
    ../../modules/services/immich.nix
    ../../modules/services/qbittorrent-nox.nix
    ../../modules/system/ssh.nix
    ../../modules/services/air-vpn.nix
    ../../modules/services/file-server.nix
    #    ../../modules/services/matrix.nix
    #    ../../modules/services/teamspeak3.nix
    ../../modules/services/calibre.nix
  ];

  networking.hostId = "d48f462c";
  networking.firewall.defaultInterfaces = [ "enp34s0" ];
  system.stateVersion = "23.05";
}
