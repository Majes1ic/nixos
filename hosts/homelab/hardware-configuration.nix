# WARN: This is just a placeholder a needs to be regenerated for the new
# hardware
{
  config,
  lib,
  pkgs,
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

  #force zfs root pool's during early boot
  boot.zfs.forceImportRoot = false;
  boot.zfs.pools.homelab-zpool.devNodes = "/dev/disk/by-label/homelab-zpool";
  boot.zfs.pools.homelab-zpool-1.devNodes = "/dev/disk/by-id";
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
        }
      ];
    };
  };

  systemd.services = {
    # This fixes an issue where the wireguard interface goes inactive if the endpoint
    # uses DDNS and the IP address changes after the interface went up.
    wg-quick-reresolve-dns = {
      description = "wg-quick reresolve DNS endpoints";
      after = [
        "network.target"
        "network-online.target"
      ];
      wants = [ "network-online.target" ];
      startAt = "*-*-* *:0/5:00"; # run every 5 mins
      serviceConfig = {
        Type = "oneshot";
        ExecStart =
          let
            checkPeer = pkgs.writeShellApplication {
              name = "wg-quick-check-peer";
              runtimeInputs = [ pkgs.wireguard-tools ];
              text = ''
                # Simplified version of wireguard-tools' reresolve-dns.sh script
                # SPDX-License-Identifier: GPL-2.0
                #
                # Copyright (C) 2015-2020 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
                INTERFACE="$1"
                PUBLIC_KEY="$2"
                ENDPOINT="$3"

                [[ $(wg show "$INTERFACE" latest-handshakes) =~ ''${PUBLIC_KEY//+/\\+}\	([0-9]+) ]] || exit 0
                (( (EPOCHSECONDS - BASH_REMATCH[1]) > 135 )) || exit 0
                wg set "$INTERFACE" peer "$PUBLIC_KEY" endpoint "$ENDPOINT"
                echo "interface=$INTERFACE peer=$PUBLIC_KEY: stale handshake, re-applied endpoint $ENDPOINT"
              '';
            };
          in
          lib.concatMap (
            interface:
            map (
              peer: ''-${lib.getExe checkPeer} "${interface}" "${peer.publicKey}" "${peer.endpoint}"''
            ) config.networking.wg-quick.interfaces.${interface}.peers
          ) (lib.attrNames config.networking.wg-quick.interfaces);
      };
    };
    zpool-health = {
      startAt = "*:0/5"; # runs every 5 minutes
      serviceConfig.Type = "oneshot";
      path = [
        pkgs.zfs
        pkgs.curl
        pkgs.gnugrep
      ];
      script = ''
        if zpool status -x | grep -q "all pools are healthy"; then
          curl -fsS -m 10 "https://status.494203.xyz/api/push/3Z63zR0VuAtAmoRXx1ZxWp0iUuX47RR7?status=up&msg=OK&ping="
        fi
      '';
    };

    wg-quick-wg-discord.serviceConfig = {
      Restart = "on-failure";
      RestartSec = 30;
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
