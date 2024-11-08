{
  lib,
  pkgs,
  username,
  ...
}:
let
  extensions = with pkgs.gnomeExtensions; [
    appindicator
    dash-to-dock
    night-theme-switcher
  ];
in
{
  # Disable gnome power profile functionality
  services.upower.enable = lib.mkForce false;
  services.power-profiles-daemon.enable = lib.mkForce false;

  # The wiki says this is needed for systray icons
  services.gnome.gnome-settings-daemon.enable = true;

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  environment.systemPackages =
    extensions
    ++ (with pkgs; [
      dconf-editor
      gnome-tweaks
    ]);

  # Enables wayland support in Chromium and Electron based applications
  environment.sessionVariables.NIXOS_OZONE_WL = 1;

  home-manager.users.${username} = {
    # Change default color theme for all GTK4 applications to dark
    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };

        "org/gnome/desktop/peripherals/mouse" = {
          accel-profile = "flat";
        };

        "org/gnome/desktop/wm/preferences" = {
          action-middle-click-titlebar = "toggle-maximize-vertically";
          button-layout = "appmenu:minimize,close";
          # Focus follows mouse
          focus-mode = "sloppy";
          resize-with-right-button = true;
        };

        "org/gnome/mutter" = {
          edge-tiling = true;
        };

        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = false;
          night-light-schedule-automatic = true;
        };

        # Allow apps to use location for sunrise/sunset time
        "org/gnome/system/location" = {
          enabled = true;
        };

        "org/gnome/settings-daemon/plugins/power" = {
          # Set power button to power off system
          power-button-action = "interactive";
          # Disable inactive suspend
          sleep-inactive-ac-type = "nothing";
        };

        "org/gnome/shell" = {
          # Enable our installed extenions and some of the pre-installed ones
          enabled-extensions = (map (e: e.extensionUuid) extensions) ++ [
            "drive-menu@gnome-shell-extensions.gcampax.github.com"
            "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
          ];
        };

        "org/gnome/shell/extensions/nightthemeswitcher/commands" = {
          enabled = true;
          sunset = "gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Ice";
          sunrise = "gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Classic";
        };

        "org/virt-manager/virt-manager/connections" = {
          autoconnect = [ "qemu:///system" ];
          uris = [ "qemu:///system" ];
        };
      };
    };

    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
    };

    home.pointerCursor = {
      gtk.enable = true;
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };
}
