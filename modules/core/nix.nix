{
  lib,
  pkgs,
  self,
  inputs,
  username,
  hostname,
  ...
}:
{
  nixpkgs = {
    overlays = [ ];
    config.allowUnfree = true;
  };

  nix = {
    # Allows referring to flakes with nixpkgs#flake
    registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
      (lib.filterAttrs (_: lib.isType "flake")) inputs
    );

    settings = {
      # enable flakes
      experimental-features = "nix-command flakes";
      # save space by removing duplicate files from the store
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Generate rebuild command scripts
  environment.systemPackages =
    let
      inherit (lib) optional optionalString concatStringsSep;
      configDir = "/home/${username}/.config/nixos";
      rebuildCmds = [
        "switch"
        "test"
        "boot"
        "build"
        "dry-build"
        "dry-activate"
        "diff"
      ];

      rebuildScripts = map (
        cmd:
        pkgs.writeShellApplication {
          name = "rebuild-${cmd}";
          runtimeInputs = [ pkgs.nixos-rebuild ] ++ optional (cmd == "diff") pkgs.nvd;
          text = # bash
            ''
              flake="${configDir}"
              if [ ! -d $flake ]; then
                echo "Flake does not exist locally so using remote from github"
                flake="git+ssh://git@github.com/Majes1ic/NixOS.git"
              fi
              trap "popd >/dev/null 2>&1 || true" EXIT
              pushd ~ >/dev/null 2>&1

              nixos-rebuild ${if (cmd == "diff") then "build" else cmd} \
                --use-remote-sudo --flake "$flake#${hostname}" ${optionalString (cmd != "boot") "--fast"} "$@"
              ${optionalString (cmd == "diff") "nvd diff /run/current-system result"}
            '';
        }
      ) rebuildCmds;

      remoteRebuildScripts = map (
        cmd:
        let
          validation = # bash
            ''
              if [ "$#" = 0 ]; then
                echo "Usage: host-rebuild-${cmd} <hostname>"
                exit 1
              fi

              hostname=$1
              # shellcheck disable=SC2034
              ip=$2
              if [[ "$hostname" == "${hostname}" ]]; then
                echo "Error: Cannot ${cmd} remotely on local host"
                exit 1
              fi

              hosts=(${concatStringsSep " " (builtins.attrNames self.nixosConfigurations)})
              match=0
              for host in "''${hosts[@]}"; do
                if [[ $host = "$hostname" ]]; then
                  match=1
                  break
                fi
              done
              if [[ $match = 0 ]]; then
                echo "Error: Host '$hostname' does not exist" >&2
                exit 1
              fi

              flake="${configDir}"
              if [ ! -d $flake ]; then
                echo "Flake does not exist locally so using remote from github"
                flake="git+ssh://git@github.com/Majes1ic/NixOS.git"
              fi

              # Always build and store result to prevent GC deleting builds for remote hosts
              remote_builds="/home/${username}/.remote-builds/$hostname"
              mkdir -p "$remote_builds"
              trap "popd >/dev/null 2>&1 || true" EXIT
              pushd "$remote_builds" >/dev/null 2>&1
              nixos-rebuild build --flake "$flake#$hostname" ${optionalString (cmd != "boot") "--fast"} "''${@:3}"
            '';
        in
        pkgs.writeShellApplication {
          name = "host-rebuild-${cmd}";
          runtimeInputs = with pkgs; [
            nixos-rebuild
            openssh
            nvd
          ];
          text =
            validation
            + (
              if (cmd == "diff") then # bash
                ''
                  if [ ! -d "${configDir}" ]; then
                    echo "rebuild-diff requires the flake to exist locally in ${configDir}"
                    exit 1
                  fi

                  remote_system=$(ssh "${username}@$ip" readlink /run/current-system)
                  nixos_system=$(readlink "$remote_builds/result")
                  nix-copy-closure --from "$ip" "$remote_system"
                  nvd --color always diff "$remote_system" "$nixos_system"
                ''
              else
                optionalString (cmd != "build") # bash
                  ''
                    nixos-rebuild ${cmd} ${optionalString (cmd != "boot") "--fast"} \
                      --use-remote-sudo --flake "$flake#$hostname" --target-host "root@$ip" "''${@:3}"
                  ''
            );
        }
      ) rebuildCmds;

    in
    rebuildScripts ++ remoteRebuildScripts;
}
