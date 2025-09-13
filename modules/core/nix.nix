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
    overlays = [
      (final: prev: {
        jellyfin-mpv-shim = prev.jellyfin-mpv-shim.override {
          pywebview =
            (final.python313Packages.pywebview.override {
              pyqtwebengine = final.python313Packages.pyqtwebengine.override {
                libsForQt5 = final.libsForQt5 // {
                  qtwebengine = final.libsForQt5.qtwebengine.overrideAttrs (old: {
                    meta = old.meta // {
                      knownVulnerabilities = [ ];
                    };
                  });
                };
              };
            }).overrideAttrs
              { doInstallCheck = false; };
        };

        jellyfin-media-player = prev.jellyfin-media-player.override {
          qtwebengine = final.libsForQt5.qtwebengine.overrideAttrs (old: {
            meta = old.meta // {
              knownVulnerabilities = [ ];
            };
          });
        };
      })
    ];
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
      inherit (lib) optionals optionalString concatStringsSep;
      configDir = "/home/${username}/.config/nixos";
      rebuildCmds = [
        "switch"
        "test"
        "boot"
        "build"
        "diff"
      ];

      rebuildScripts = map (
        cmd:
        pkgs.writeShellApplication {
          name = "rebuild-${cmd}";
          runtimeInputs = [ pkgs.nh ];
          text = ''
            flake="${configDir}"
            if [ ! -d $flake ]; then
              echo "Flake does not exist locally so using remote from github"
              flake="git+ssh://git@github.com/Majes1ic/NixOS.git"
            fi

            nh os ${
              if (cmd == "diff") then "build" else cmd
            } "$flake" --hostname ${hostname} --out-link ~/result-${hostname} "$@"
          '';
        }
      ) rebuildCmds;

      remoteRebuildScripts = map (
        cmd:
        let
          validation = # bash
            ''
              if [ "$#" = 0 ]; then
                echo "Usage: host-rebuild-${cmd} <hostname>${optionalString (cmd != "build") " <ip-address>"}"
                exit 1
              fi

              hostname=$1
              ${optionalString (cmd != "build") "ip=$2"}

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
              remote_builds="/home/${username}/.remote-builds"
              mkdir -p "$remote_builds"
            '';
        in
        pkgs.writeShellApplication {
          name = "host-rebuild-${cmd}";
          runtimeInputs = [
            pkgs.nh
          ]
          ++ optionals (cmd == "diff") [
            pkgs.nix
            pkgs.openssh
            pkgs.dix
          ];
          text =
            validation
            + (
              if (cmd == "build" || cmd == "diff") then
                ''
                  nh os build "$flake" --hostname "$hostname" --out-link "$remote_builds/result-$hostname" "''${@:3}"
                  ${optionalString (cmd == "diff") ''
                    remote_system=$(ssh "root@$ip" readlink /run/current-system)
                    built_system=$(readlink "$remote_builds/result-$hostname")
                    nix copy --from "ssh://$ip" "$remote_system"
                    dix "$remote_system" "$built_system"
                  ''}
                ''
              else
                ''
                  nh os ${cmd} "$flake" --hostname "$hostname" --out-link "$remote_builds/result-$hostname" --target-host "root@$ip" "''${@:3}"
                ''
            );
        }
      ) rebuildCmds;

    in
    rebuildScripts ++ remoteRebuildScripts;
}
