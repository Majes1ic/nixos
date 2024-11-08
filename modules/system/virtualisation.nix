{
  lib,
  pkgs,
  config,
  username,
  ...
}:
let
  cfg = config.custom.virtualisation;

  runVMScript = pkgs.writeShellApplication {
    name = "run-vm";
    runtimeInputs = with pkgs; [
      gnugrep
      gnused
      gnutar
      age
      openssh
    ];
    text = # bash
      ''
        if [ "$#" -ne 1 ]; then
          echo "Usage: run-vm <hostname>"
          exit 1
        fi
        hostname=$1

        flake="/home/${username}/.config/nixos"
        if [ ! -d $flake ]; then
          echo "Flake does not exist locally so using remote from github"
          flake="git+ssh://git@github.com/Majes1ic/NixOS.git"
        fi

        # Build the VM
        runscript="/home/${username}/result/bin/run-$hostname-vm"
        pushd "/home/${username}" > /dev/null
        nixos-rebuild build-vm --flake "$flake#$hostname"

        # Print ports mapped to the VM
        printf '\nMapped Ports:\n%s\n' "$(grep -o 'hostfwd=[^,]*' "$runscript" | sed 's/hostfwd=//g')"

        # Run the VM
        $runscript
      '';
  };
in
{
  options.custom.virtualisation = {
    graphicalVM = lib.mkEnableOption "graphical VM variant";
  };

  config = {
    environment.systemPackages = [ runVMScript ];
    programs.virt-manager.enable = true;
    virtualisation.libvirtd.enable = true;
    users.users.${username}.extraGroups = [ "libvirtd" ];

    virtualisation.vmVariant.virtualisation = {
      cores = 4;
      memorySize = 4096;
      diskSize = 8192;
      graphics = cfg.graphicalVM;

      qemu.options = lib.mkIf cfg.graphicalVM [
        # sdl might be better than gtk on Nvidia
        "-device virtio-vga-gl"
        "-display gtk,gl=on"
        # Non-OpenGL version:
        # "-device virtio-vga"
        # "-display gtk"
      ];

      # Forward all TCP and UDP ports that are opened in the firewall on
      # the default interfaces. Should make the majority of the VMs
      # services accessible from host.
      forwardPorts =
        let
          inherit (config.virtualisation.vmVariant.networking.firewall) allowedTCPPorts allowedUDPPorts;

          forward = proto: port: {
            from = "host";
            # If not mapped, attempt to map host port to a unique value between 50000-65000
            host = {
              port = (lib.mod port 15001) + 50000;
              address = "127.0.0.1";
            };
            guest.port = port;
            proto = proto;
          };
        in
        map (forward "tcp") allowedTCPPorts ++ map (forward "udp") allowedUDPPorts;
    };
  };
}
