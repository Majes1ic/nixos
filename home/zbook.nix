{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./core.nix
  ];

  home.packages = with pkgs; [
    alacritty
    kitty
    discord
    lua
    qpwgraph
    lazygit
    jellyfin-mpv-shim
    easyeffects
    yazi
    chatterino7
    wl-clipboard
    tor-browser
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withRuby = false;
    withPython3 = false;

    extraPackages = with pkgs; [
      # Runtime dependencies
      fzf
      lua-language-server
      nixd
      nil
      stylua
      nixfmt
      ripgrep
      gnumake
      gcc
      luajit
      tree-sitter
    ];
  };

  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
  };

  programs.mpv = {
    enable = true;
    config = {
      profile = "gpu-hq";
      hwdec = "auto";
      volume = "50";
    };
  };
  home.pointerCursor.enable = true;
  home.stateVersion = "26.05";
}
