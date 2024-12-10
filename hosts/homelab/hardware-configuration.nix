# WARN: This is just a placeholder a needs to be regenerated for the new
# hardware
{
  config,
  lib,
  modulesPath,
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

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.nvidia.open = lib.mkForce false;
}
