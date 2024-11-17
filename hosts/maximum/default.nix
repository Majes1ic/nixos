{ pkgs, username, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
    ../../modules/hardware/windows.nix
    ../../modules/hardware/nvidia.nix
    ../../modules/hardware/audio.nix
    ../../modules/hardware/networking.nix
    ../../modules/system/firewall.nix
    ../../modules/system/gnome.nix
    ../../modules/system/ssh.nix
    ../../modules/system/virtualisation.nix
    ../../modules/programs/steam.nix
  ];

  custom.virtualisation.graphicalVM = true;

  environment.systemPackages = with pkgs; [
    lm_sensors
  ];

  # WIREGUARD #
  networking.wg-quick.interfaces = {
    wg-discord = {
      address = [ "10.0.0.6/24" ];
      autostart = true;
      privateKeyFile = "/home/${username}/.wireguard/private";
      peers = [
        {
          publicKey = "PbFraM0QgSnR1h+mGwqeAl6e7zrwGuNBdAmxbnSxtms=";
          allowedIPs = [ "10.0.0.0/24" ];
          endpoint = "he908z488kp.sn.mynetname.net:13232";
          persistentKeepalive = 25;
        }
      ];
    };

    wg-home = {
      address = [ "10.0.1.1/24" ];
      listenPort = 51820;
      autostart = true;
      privateKeyFile = "/home/${username}/.wireguard/private";

      peers = [
        {
          # laptop
          publicKey = "T1EHPg4tkmQ1KFWGzspBYAkjzLL1JzWTNtPsSkObLUE=";
          allowedIPs = [ "10.0.1.2/32" ];
        }
        {
          # phone
          publicKey = "xDDnUvzTcSGA4htsmYBSQykgLVv/MCEUwEKc+IOoL3w=";
          allowedIPs = [ "10.0.1.3/32" ];
        }
      ];
    };

    wg-air = {
      configFile = "/etc/wireguard/AirVPN_Swiss_Maximum.conf";
      autostart = false;
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
    interfaces.wg-air.allowedTCPPorts = [ 36780 ];
    interfaces.wg-air.allowedUDPPorts = [ 36780 ];
  };

  programs.zsh.shellAliases = {
    wg-discord-up = "sudo systemctl start wg-quick-wg-discord";
    wg-discord-down = "sudo systemctl stop wg-quick-wg-discord";
    wg-home-up = "sudo systemctl start wg-quick-wg-home";
    wg-home-down = "sudo systemctl stop wg-quick-wg-home";
    wg-air-up = "sudo systemctl start wg-quick-wg-air";
    wg-air-down = "sudo systemctl stop wg-quick-wg-air";
  };

  networking.hostId = "150ce5b1";
  networking.firewall.defaultInterfaces = [ "enp3s0" ];
  system.stateVersion = "23.05";
}
