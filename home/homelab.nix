{ pkgs, ... }:
{
  imports = [ ./core.nix ];

  home.packages = with pkgs; [
    micro
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      #runtime dependencies
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

  home.stateVersion = "24.05";
}
