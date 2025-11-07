{ pkgs, ... }:

{
  services.sunshine = {
    enable = true;
    autoStart = false;
    package = pkgs.sunshine.override { cudaSupport = true; };
    openFirewall = true;
    capSysAdmin = true;
  };
}
