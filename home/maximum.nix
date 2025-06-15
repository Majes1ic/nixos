{
  pkgs,
  cfg,
  config,
  ...
}:
{
  imports = [
    ./core.nix
    ./programs/vscode.nix
  ];

  home.packages =
    with pkgs;
    [
      kitty
      micro
      xdg-utils # because vs code doesn't work without it
      vesktop # discord client
      discord
      mumble
      prismlauncher
      bitwarden-desktop
      stremio
      qbittorrent
      qpwgraph # audio piping (patch panel)
      lua
      zed-editor
      #      gnomeExtensions.easyeffects-preset-selector
      easyeffects
      jellyfin-mpv-shim
      jellyfin-media-player
      lazygit
      bottles
      winbox4
      wl-clipboard
      chromium
      tor
      tor-browser
      #      teamspeak5_client
      chatterino7
      yazi
    ]
    ++ [

      (makeDesktopItem {
        name = "broadcast-box";
        desktopName = "Broadcast Box";
        type = "Application";
        exec = "chromium --app=https://stream.908005.xyz";
        icon = pkgs.fetchurl {
          url = "https://avatars.githubusercontent.com/u/67584243?s=200&v=4";
          hash = "sha256-12eai258gfzlt+XT3mrHF9DvD9YlHf5yLjQFy8EbLFM=";
        };
      })
    ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      # Runtime dependencies
      fzf
      lua-language-server
      nixd
      nil
      stylua
      nixfmt-rfc-style
      ripgrep
      gnumake
      gcc
      luajit
      tree-sitter
    ];
  };

  programs.firefox = {
    enable = true;
  };

  programs.obs-studio = {
    enable = true;

    package = pkgs.obs-studio.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        (pkgs.fetchpatch {
          name = "webrtc-pacing-handler";
          url = "https://github.com/obsproject/obs-studio/commit/2aae0f4d6849a7c23f44760f548e13f3a307426b.patch";
          hash = "sha256-VKNA0N4JHat/tLSRk3CLY+NcHsIoIvRHYfHo572KSGk=";
        })
      ];
    });

    plugins = [
      (pkgs.obs-studio-plugins.obs-pipewire-audio-capture.overrideAttrs {
        version = "2024-09-04";
        src = pkgs.fetchFromGitHub {
          owner = "dimtpap";
          repo = "obs-pipewire-audio-capture";
          rev = "c8c57b39fddf01c365f3d1234edc983ee0da1b5b";
          hash = "sha256-qdwJS4WJxoIg2lIq3aHgBBrQr0Y56X4eZJzOjkwXegE=";
        };
        cmakeFlags = [ ];
      })
    ];
  };

  programs.mpv = {
    enable = true;
    config = {
      profile = "gpu-hq";
      hwdec = "auto";
      volume = "50";
    };
  };

  xdg.configFile = {
    "jellyfin-mpv-shim/mpv.conf".source = config.xdg.configFile."mpv/mpv.conf".source;
  };

  programs.mangohud = {
    enable = true;
    settings = {
      full = true;
    };
  };

  home.stateVersion = "23.05";
}
