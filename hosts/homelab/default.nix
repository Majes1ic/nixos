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
    ../../modules/system/ssh.nix
    # Wireguards needs options for customising
    # ../../modules/services/wireguard.nix
  ];

  networking.hostId = "d48f462c";
  networking.firewall.defaultInterfaces = [ "enp34s0" ];
  system.stateVersion = "23.05";
}
