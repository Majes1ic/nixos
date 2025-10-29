{ pkgs, ... }:

{
  services.sunshine = {
    enable = true;
    autoStart = true;
    package = pkgs.sunshine.override { cudaSupport = true; };
    openFirewall = true;
    capSysAdmin = true;
  };
}
