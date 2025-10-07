# WARN: This is just a placeholder a needs to be regenerated for the new
# hardware
{
  config,
  lib,
  modulesPath,
  username,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];

  # amd kernel
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # enable zfs support
  boot.supportedFilesystems.zfs = true;

  boot.zfs.pools.homelab-zpool.devNodes = "/dev/disk/by-label/homelab-zpool";
  boot.zfs.pools.homelab-zpool-1.devNodes = "/dev/disk/by-label/homelab-zpool-1";
  boot.zfs.extraPools = [
    "homelab-zpool"
    "homelab-zpool-1"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/homelab-nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/homelaboot";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  # fileSystems."/data" = {
  #   device = "/dev/disk/by-label/Mercury";
  #   #fsType = "ext4";
  # };
  # fileSystems."/mnt/Gemini" = {
  #   device = "/dev/disk/by-label/Gemini";
  #   #fsType = "ext4";
  # };

  #enables trimming
  services.fstrim.enable = true;

  networking.wg-quick.interfaces = {
    wg-discord = {
      address = [ "10.0.0.9/24" ];
      autostart = true;
      privateKeyFile = "home/${username}/.wireguard/privatekey";
      listenPort = 51821;
      peers = [
        {
          publicKey = "PbFraM0QgSnR1h+mGwqeAl6e7zrwGuNBdAmxbnSxtms=";
          presharedKeyFile = "/etc/wireguard/discord-presharedKeyFile.txt";
          allowedIPs = [ "10.0.0.0/24" ];
          endpoint = "he908z488kp.sn.mynetname.net:13232";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "logind"
      "systemd"
    ];
    disabledCollectors = [
      "textfile"
    ];
  };

  networking.firewall.interfaces = {
    # wg-discord.allowedTCPPorts = [ 22 ];
    wg-home.allowedTCPPorts = [ 9100 ];
    enp34s0.allowedTCPPorts = [ 9100 ];
  };

  programs.zsh.shellAliases = {
    wg-discord-up = "sudo systemctl start wg-quick-wg-discord";
    wg-discord-down = "sudo systemctl stop wg-quick-wg-discord";
    wg-home-up = "sudo systemctl start wg-quick-wg-home";
    wg-home-down = "sudo systemctl stop wg-quick-wg-home";
    wg-air-up = "sudo systemctl start wg-quick-wg-air";
    wg-air-down = "sudo systemctl stop wg-quick-wg-air";
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.nvidia.open = lib.mkForce false;
}
