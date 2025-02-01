{ pkgs, ... }:
{
  hardware.new-lg4ff.enable = true;
  services.udev.packages = [ pkgs.oversteer ];
  environment.systemPackages = [ pkgs.oversteer ];
}
