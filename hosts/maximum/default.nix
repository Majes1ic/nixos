{
  lib,
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

    ../../modules/core

    ../../modules/hardware/nvidia.nix
    ../../modules/hardware/audio.nix
    ../../modules/hardware/networking.nix
    ../../modules/hardware/secure-boot.nix
    ../../modules/hardware/wheel.nix

    ../../modules/system/firewall.nix
    #../../modules/system/gnome.nix
    ../../modules/system/hyprland.nix
    (lib.modules.importApply ../../modules/system/ssh.nix { desktop = true; })
    ../../modules/system/virtualisation.nix

    ../../modules/programs/audio.nix
    ../../modules/programs/steam.nix

    #../../modules/services/llama.nix
    ../../modules/services/sunshine.nix
  ];

  custom.virtualisation.graphicalVM = true;

  environment.systemPackages = with pkgs; [
    lm_sensors
    code-cursor
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
          presharedKeyFile = "/etc/wireguard/discord-presharedKeyFile.txt";
          allowedIPs = [ "10.0.0.0/24" ];
          endpoint = "he908z488kp.sn.mynetname.net:13232";
          persistentKeepalive = 25;
        }
      ];
    };

    wg-home = {
      address = [ "10.0.1.10/24" ];
      autostart = true;
      privateKeyFile = "/home/${username}/.wireguard/private";

      peers = [
        #  {
        #    # laptop
        #    publicKey = "nlXSThJ4KDhpaEVeDgkvKyL5kopIgMqs2rmdg5VnmnU=";
        #    allowedIPs = [ "10.0.1.11/32" ];
        #  }
        #  {
        #    # phone
        #    publicKey = "xDDnUvzTcSGA4htsmYBSQykgLVv/MCEUwEKc+IOoL3w=";
        #    allowedIPs = [ "10.0.1.3/32" ];
        #  }
        {
          publicKey = "RZu9z1llyyWIb/Bn4oxde299W1J0ZUIrGY5HZX2OgFI=";
          allowedIPs = [ "10.0.1.0/24" ];
          endpoint = "hh90a7hr8zt.sn.mynetname.net:51820";
          persistentKeepalive = 60;
        }
      ];
    };

    wg-air = {
      configFile = "/etc/wireguard/AirVPN_Swiss_Maximum.conf";
      autostart = false;
    };
  };

  networking.firewall = {
    # allowedUDPPorts = [ 51820 ];
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
  networking.firewall.defaultInterfaces = [ "wg-home" ];
  system.stateVersion = "23.05";

  #temp beamMP
  #security.pki.certificateFiles = [
  #  (pkgs.stdenvNoCC.mkDerivation {
  #    name = "beammp-cert";
  #    nativeBuildInputs = [ pkgs.curl ];
  #    builder = pkgs.writeScript "beammp-cert-builder" "curl -w %{certs} https://auth.beammp.com/userlogin -k > $out";
  #    outputHash = "sha256-IjPAWvD57XCoCqJ7cq5/Jr2w4Y17iFW7ws6/xMpDLBU=";
  #  })
  #];
}
