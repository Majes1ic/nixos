{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

    ../../modules/core

    ../../modules/hardware/audio.nix
    ../../modules/hardware/networking.nix
    # Enable AFTER the first boot (lanzaboote needs keys created with sbctl first)
    # ../../modules/hardware/secure-boot.nix

    ../../modules/system/firewall.nix
    ../../modules/system/hyprland.nix
    (lib.modules.importApply ../../modules/system/ssh.nix { desktop = true; })
    ../../modules/system/virtualisation.nix

    ../../modules/programs/audio.nix
  ];

  custom.virtualisation.graphicalVM = true;

  # Plain systemd-boot for the first install. secure-boot.nix should take over
  # from this once enabled (mkDefault lets it override cleanly).
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Hardware
  hardware.enableRedistributableFirmware = true; # Wi-Fi, Bluetooth, audio firmware
  hardware.bluetooth.enable = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  # Laptop power / thermals / housekeeping
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = true; # don't enable alongside tlp
  services.upower.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;
  zramSwap.enable = true;

  environment.systemPackages = with pkgs; [
    lm_sensors
    brightnessctl
  ];

  # No networking.hostId needed: that's only required for ZFS.
  # No networking.hostName either, assuming modules/core sets it from the
  # `hostname` specialArg like it does for maximum.

  system.stateVersion = "26.05"; # match `nixos-version` on the installer if it differs
}
