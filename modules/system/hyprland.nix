{
  lib,
  pkgs,
  inputs,
  config,
  username,
  ...
}:
let
  inherit (config.custom.virtualisation) vmVariant;
in
{
  # use package from hyprland flake
  nixpkgs.overlays = lib.singleton (
    final: _: {
      hyprland = inputs.hyprland.packages.${pkgs.system}.hyprland;
      xdg-desktop-portal-hyprland =
        inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland.override
          {
            inherit (final) hyprland;
          };
    }
  );

  # hyprland binary cache
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  security.pam.services.hyprlock = { };

  # managed with home-manager
  xdg.portal.enable = lib.mkForce false;

  # polkit-agent
  systemd.packages = [ pkgs.hyprpolkitagent ];
  systemd.user.services.hyprpolkitagent = {
    path = lib.mkForce [ ];
    serviceConfig.Slice = "background-graphical.slice";
    wantedBy = [ "graphical-session.target" ];
  };

  # notifies if user services fail
  systemd.user.services.fumon = {
    enable = true;
    wantedBy = [ "graphical-session.target" ];
    path = lib.mkForce [ ];
    serviceConfig.ExecStart = [
      "" # to replace original ExecStart
      (lib.getExe' pkgs.uwsm "fumon")
    ];
  };

  # automatically populate with primary user whilst still prompting for password
  services.getty = {
    autologinUser = "tom";
    #loginOptions = username;
    #extraArgs = [ "--skip-login" ];
  };

  # Disable timeout as with --skip-login the default timeout of 60 seconds
  # causes it to repeatedly timeout indefinitely
  security.loginDefs.settings.LOGIN_TIMEOUT = 0;

  # If not ssh and uwsm is allowed to start, launch hyprland.desktop with uwsm
  environment.loginShellInit = lib.mkOrder 2000 ''
    if test -z $SSH_TTY && uwsm check may-start -q; then
      exec uwsm start ${pkgs.hyprland}/share/wayland-sessions/hyprland.desktop >/dev/null
    fi

    # ensure home-manager variables have precedence over system variables
    . "/etc/profiles/per-user/${username}/etc/profile.d/hm-session-vars.sh"
  '';

  # Necessary for xdg-portal home-manager module to work with useUserPackages enabled
  # https://github.com/nix-community/home-manager/pull/5184
  # NOTE: When https://github.com/nix-community/home-manager/pull/2548 gets
  # merged this may no longer be needed
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];

  home-manager.users.${username} = {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false; # we use uwsm instead
      package = null;
      portalPackage = null;
      settings =
        let
          mod = if vmVariant then "ALT" else "SUPER";
          modShift = "${mod}SHIFT";
          modShiftCtrl = "${mod}SHIFTCONTROL";
        in
        {
          monitor = [
            "HDMI-A-1, 3840x2160@120, 1920x0, 1"
            "DP-2, 2560x1440@75, 0x2160, 1"
            "DP-3, 2560x1440@360, 2560x2160, 1"
          ];
          input.accel_profile = "flat";
          cursor.enable_hyprcursor = false;

          general = {
            border_size = 2;
            gaps_out = 10;
            resize_on_border = true;
          };

          decoration = {
            rounding = 10;
            blur = {
              enabled = true;
              special = true;
              size = 2;
              passes = 3;
            };
          };

          #layerrule = [ "blur, launcher" ];

          animations = {
            enabled = true;

            bezier = [
              "easeInOutQuart,0.76,0,0.24,1"
              "fluentDecel, 0, 0.2, 0.4, 1"
              "easeOutCirc, 0, 0.55, 0.45, 1"
              "easeOutCubic, 0.33, 1, 0.68, 1"
              "easeinoutsine, 0.37, 0, 0.63, 1"
              "easeOutQuint, 0.23, 1, 0.32, 1"
            ];

            animation = [
              "windowsIn, 1, 3, easeOutCubic, popin 30%"
              "windowsOut, 1, 3, fluentDecel, popin 70%"
              "windowsMove, 1, 4, easeOutQuint"
              "fadeIn, 1, 3, easeOutCubic"
              "fadeOut, 1, 1.7, easeOutCubic"
              "fadeSwitch, 0, 1, easeOutCirc"
              "fadeDim, 1, 4, fluentDecel"
              "workspaces, 1, 3, easeOutCubic, slide"
              "specialWorkspace, 1, 3, easeOutCubic, slidevert"
              "layers, 1, 4, easeOutQuint"
            ];
          };

          bind = [
            "${mod}, H, movefocus, l"
            "${mod}, L, movefocus, r"
            "${mod}, K, movefocus, u"
            "${mod}, J, movefocus, d"
            "${modShift}, J, workspace, m-1"
            "${modShift}, K, workspace, m+1"
            "${mod}, mouse:275, workspace, m-1"
            "${mod}, mouse_down, workspace, e-1"
            "${mod}, mouse:276, workspace, m+1"
            "${mod}, mouse_up, workspace, e+1"
            "${mod}, Left, movewindow, l"
            "${mod}, Right, movewindow, r"
            "${mod}, Up, movewindow, u"
            "${mod}, Down, movewindow, d"
            "${modShift}, Left, movetoworkspace, r-1"
            "${modShift}, Right, movetoworkspace, r+1"

            "${mod}, W, killactive"
            "${mod}, C, togglefloating"
            "${mod}, F, fullscreen, 1"
            "${modShift}, F, fullscreen, 0"
            "${modShiftCtrl}, Q, exec, loginctl terminate-session \"$XDG_SESSION_ID\""

            "${mod}, TAB, focusmonitor, +1"

            "${mod}, Return, exec, uwsm app Alacritty.desktop"
            "${mod}SHIFT, Return, workspace, emptym"
            "${mod}SHIFT, Return, exec, uwsm app Alacritty.desktop"

            "${mod}, Space, exec, uwsm app firefox.desktop"
            "${mod}SHIFT, Space, workspace, emptym"
            "${mod}SHIFT, Space, exec, uwsm app firefox.desktop"

            "${mod}, D, togglespecialworkspace, social"
            "${modShift}, D, movetoworkspacesilent, special:social"

            "${modShift}, S, exec, hyprshot -m region --clipboard-only"

            "${mod}, G, workspace, name:game"
            "${modShift}, G, movetoworkspace, name:game"

            #"${mod}, ctrl, G,
          ]
          ++ lib.flatten (
            lib.genList (
              x:
              let
                key = toString x;
                w = toString (if x == 0 then 10 else x);
              in
              [
                "${mod}, ${key}, workspace, ${w}"
                "${modShift}, ${key}, movetoworkspace, ${w}"
                "${modShiftCtrl}, ${key}, movetoworkspacesilent, ${w}"
              ]
            ) 10
          );

          bindr = [ "${mod}, ${mod}_L, exec, pkill fuzzel || fuzzel" ];

          bindm = [
            "${mod}, mouse:272, movewindow"
            "${mod}, mouse:273, resizewindow"
          ];

          workspace = [
            "special:social, gapsin:20, gapsout:40"
            "name:game, monitor:DP-3"
          ];

          windowrule = [
            "match:class discord, workspace special:social silent"
            "match:content 3, workspace name:game silent, center on, fullscreen on"
            "match:class ^(steam_app_.*|hl_linux|hl2_linux)$, workspace name:game silent, center on, fullscreen on"
            #  "workspace special:social silent, title:^(Spotify( Premium)?)$"
            #  "blur, class:^(fuzzel)$"
          ];
        };

    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
          after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        };

        listener = [
          # FOR LAPTOP
          #{
          #  timeout = 150; # 2.5min.
          #  on-timeout = "brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
          #  on-resume = "brightnessctl -r"; # monitor backlight restore.
          #}
          {
            timeout = 300; # 5min
            on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
          }
          {
            timeout = 600; # 10min
            on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
            on-resume = "hyprctl dispatch dpms on && brightnessctl -r"; # screen on when activity is detected after timeout has fired.
          }
          {
            timeout = 900; # 15min
            on-timeout = "systemctl suspend"; # suspend pc
          }
        ];
      };
    };

    # Setting env vars for Nvidia as per wiki. Set in uwsm/env conf as this is recommended
    xdg.configFile."uwsm/env".text = ''
      export LIBVA_DRIVER_NAME=nvidia
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export NVD_BACKEND=direct
    '';

    # Portal acts as medium for interactions between hyprland and backend services
    xdg.portal = {
      enable = lib.mkForce true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      configPackages = [ pkgs.hyprland ];
    };

    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          launch-prefix = "uwsm app --";
          terminal = "alacritty";

          # Width of the launcher window
          width = 50; # This is a percentage of screen width
          # Number of entries to display
          lines = 15;

          # Horizontal padding inside the launcher window
          horizontal-pad = 20;
          # Vertical padding inside the launcher window
          vertical-pad = 10;

          # Font settings
          font = "monospace:size=12"; # Using monospace to match Waybar
          line-height = 20; # Gives some breathing room between entries
        };

        colors = {
          # Background of the launcher window with transparency
          background = "00000088"; # Pure black, fully opaque

          # Text color for entries
          text = "777777"; # Grey

          # Color of matching text when searching
          match = "ffffffff"; # Red to highlight matching characters

          # Selected entry background and text
          selection = "1a1a1aff"; # Dark gray for selected item background
          selection-text = "ffffffff"; # White text for selected item

          # Border color
          border = "666666ff"; # Gray border to match the theme
        };

        border = {
          # Border settings
          width = 2; # 2px border to match Dunst's frame width
          radius = 0; # Square corners to match Waybar and Dunst
        };
      };
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: FiraCode Nerd Font Mono;
          min-height: 0;
        }

        window#waybar {
          background: #000000;
          color: #ffffff;
        }

        #workspaces button {
          padding: 0 10px;
          background: #000000;
          color: #777777;  /* This is the default, unselected workspace color */
        }

        #workspaces button.active {
          color: #ffffff;  /* This makes the active workspace bright white */
          font-weight: bold;  /* Makes the active workspace number bold */
        }

        #workspaces button:hover {
          background: #1a1a1a;  /* Subtle background change on hover */
          color: #ffffff;  /* Brightens the workspace number on hover */
        }

        #window,
        #clock,
        #cpu,
        #memory,
        #tray {
          background: #000000;
          padding: 0 10px;
        }
      '';
      settings.bar = {
        layer = "top";
        height = 24;
        margin = "0 0 0 0";

        clock = {
          interval = 10;
          format = "{:%a %d %m %H:%M}";
        };

        cpu = {
          format = " {usage}%";
        };

        memory = {
          format = " {percentage}%";
        };

        tray = {
          spacing = 14;
          show-passive-items = true;
        };

        "hyprland/workspaces" = { };
        "hyprland/window" = {
          max-length = 60;
          separate-outputs = true;
        };

        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "cpu"
          "memory"
          "tray"
        ];
      };
    };

    systemd.user.services.waybar = {
      Unit.After = lib.mkForce [ "graphical-session.target" ];
      Service.Slice = "app-graphical.slice";
    };

    services.dunst = {
      enable = true;
      settings = {
        # Global settings for notifications
        global = {
          # Display settings
          monitor = 1;
          follow = "none";
          width = 400;
          height = 300;
          origin = "top-right";
          offset = "20x50";
          scale = 0;
          notification_limit = 20;

          # Progress bar settings
          progress_bar = true;
          progress_bar_height = 10;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 300;

          # Theme settings that match your black theme
          frame_width = 2;
          frame_color = "#000000";
          separator_height = 10;
          separator_color = "#666666";
          padding = 12;
          horizontal_padding = 12;
          gap_size = 8;
          text_icon_padding = 0;

          # Font configuration
          font = "monospace 10";
          line_height = 0;
          markup = "full";
          format = "<b>%s</b>\n%b";
          alignment = "left";
          vertical_alignment = "center";

          # Appearance tweaks
          icon_position = "left";
          min_icon_size = 32;
          max_icon_size = 128;
          corner_radius = 0; # Square corners to match waybar

          # Behavior settings
          sort = true;
          idle_threshold = 120;
          show_age_threshold = 60;
        };

        # Styling for urgent notifications
        urgency_low = {
          background = "#000000";
          foreground = "#ffffff";
          timeout = 10;
        };

        urgency_normal = {
          background = "#000000";
          foreground = "#ffffff";
          timeout = 10;
        };

        urgency_critical = {
          background = "#000000";
          foreground = "#ff0000"; # Red text for critical notifications
          frame_color = "#ff0000"; # Red frame for critical notifications
          timeout = 0; # Don't auto-dismiss critical notifications
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

    # Hyprpaper needs a config file otherwise it core dumps
    xdg.configFile."hypr/hyprpaper.conf".text = ''
      ipc=true
      preload = /home/tom/Pictures/wallpaper-0.png
      wallpaper = , /home/tom/Pictures/wallpaper-0.png
    '';

    systemd.user.services.hyprpaper = {
      Unit = {
        Description = "Hyprpaper Wallpaper Daemon";
        PartOf = [ "graphical-session.target" ];
        Requires = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        Slice = "background-graphical.slice";
        ExecStart = lib.getExe pkgs.hyprpaper;
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };

    xdg.configFile."hypr/hyprlock.conf".text = ''


      background {
        monitor = DP-3
        path = /home/tom/Pictures/wallpaper-0.png
        blur_passes = 3
      }

      label {
        text = Beep Boop
        font_size = 20
        halign = center
        valign = top
        position = 0, -100
      }
      input-field {
        monitor = DP-3
        size = 200, 50
        outline_thickness = 2
        dots_size = 0.3
        dots_spacing = 0.2
        fade_on_empty = true
        placeholder_text = <i>Enter password...</i>
        hide_input = false
        position = 0, 0
        valign = center
        halign = center
      }
    '';

    home.packages = with pkgs; [
      hyprshot
      hyprlock
      brightnessctl
    ];
  };
}
