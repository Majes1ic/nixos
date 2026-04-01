{ pkgs, ... }:
{
  # Better windows syncing primitives for improved performance in
  # multi-threaded games ran through wine or proton
  boot.kernelModules = [ "ntsync" ];

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  programs.steam = {
    enable = true;
    protontricks.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
}
