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
    loginOptions = username;
    extraArgs = [ "--skip-login" ];
    helpLine = lib.mkForce "";
  };

  # Disable timeout as with --skip-login the default timeout of 60 seconds
  # causes it to repeatedly timeout indefinitely
  security.loginDefs.settings.LOGIN_TIMEOUT = 0;

  # If not ssh and uwsm is allowed to start, launch hyprland.desktop with uwsm
  environment.loginShellInit = lib.mkOrder 2000 ''
    if test -z $SSH_TTY && uwsm check may-start -q; then
      exec uwsm start -S -- ${pkgs.hyprland}/share/wayland-sessions/hyprland.desktop >/dev/null
    fi

    # ensure home-manager variables have precedence over system variables
    . "/etc/profiles/per-user/${username}/etc/profile.d/hm-session-vars.sh"
  '';

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
          input.accel_profile = "flat";
          cursor.enable_hyprcursor = false;
          decoration.rounding = 10;

          binds =
            [
              "${mod}, H, movefocus, l"
              "${mod}, L, movefocus, r"
              "${mod}, K, movefocus, u"
              "${mod}, J, movefocus, d"
              "${modShift}, J, workspace, m-1"
              "${modShift}, K, workspace, m+1"
              "${mod}, mouse:275, workspace, m-1"
              "${mod}, mouse:276, workspace, m+1"
              "${mod}, Left, movewindow, l"
              "${mod}, Right, movewindow, r"
              "${mod}, Up, movewindow, u"
              "${mod}, Down, movewindow, d"

              "${mod}, W, killactive,"
              "${mod}, C, exec, togglefloating"
              "${mod}, F, exec, fullscreen 1"
              "${modShift}, F, exec, fullscreen 0"
              "${modShiftCtrl}, Q, exec, loginctl terminate-session \"$XDG_SESSION_ID\""

              "${mod}, TAB, focusmonitor, +1"

              "${mod}, Return, exec, uwsm app kitty.desktop"
              "${mod}SHIFT, Return, workspace, emptym"
              "${mod}SHIFT, Return, exec, uwsm app kitty.desktop"

              "${mod}, Space, exec, uwsm app firefox.desktop"
              "${mod}SHIFT, Space, workspace, emptym"
              "${mod}SHIFT, Space, exec, uwsm app firefox.desktop"

              "${mod}, S, togglespecialworkspace, social"
              "${modShift}, S, movetoworkspacesilent, special:social"
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

          windowrulev2 = [
            "workspace special:social silent, class:^(vesktop|discord)$, title:^(Discord.*)$"
            "workspace special:social silent, title:^(Spotify( Premium)?)$"
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
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      configPackages = [ pkgs.hyprland ];
    };

    programs.fuzzel = {
      enable = true;
      settings.main.launch-prefix = "uwsm app --";
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings.bar = {
        layer = "top";
        height = 24;
        margin = "0 0 0 0";

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
          "network"
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
  };
}