{ pkgs, ... }:
{
  imports = [ ./core.nix ];

  home.packages = with pkgs; [
    neovim
    micro
  ];

  home.stateVersion = "24.05";
}
