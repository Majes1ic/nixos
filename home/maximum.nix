{ pkgs, ... }:
{
  imports = [
    ./core.nix
    ./programs/vscode.nix
  ];

  home.packages = with pkgs; [
    kitty
    micro
    git
    xdg-utils # because vs code doesn't work without it
    vesktop # discord client
    discord
    prismlauncher
    bitwarden-desktop
    stremio
    qbittorrent
    qpwgraph # audio piping (patch panel)
    lua
    zed-editor
    gnomeExtensions.easyeffects-preset-selector
    easyeffects
    #jellyfin-mpv-shim
    jellyfin-media-player
    lazygit
    bottles
  ];

  programs.neovim = {
    enable = true;

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
          url = "https://patch-diff.githubusercontent.com/raw/obsproject/obs-studio/pull/10966.patch";
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
    };
  };

  programs.mangohud = {
    enable = true;
    settings = {
      full = true;
    };
  };

  home.stateVersion = "23.05";
}
