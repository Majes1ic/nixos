{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  boot.loader.systemd-boot.enable = lib.mkForce false;

  environment.systemPackages = [
    pkgs.sbctl
  ];
}
