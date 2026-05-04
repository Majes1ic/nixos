{ pkgs, config, ... }:
{
  hardware.graphics = {
    enable = true;
    # nvidia hardware acceleration
    extraPackages = with pkgs; [
      libva-vdpau-driver
      nvidia-vaapi-driver
      cudatoolkit
    ];
  };

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    # Major issues if this is disabled
    modesetting.enable = true;
    open = true;
    nvidiaSettings = false;
  };
  #nixpkgs.config.cudaSupport = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  # Completely disable suspend and hibernate as it seems broken on nvidia and
  # accidentally pressing the button in gnome can put the system in a broken
  # state
  systemd = {
    targets = {
      sleep = {
        enable = false;
        unitConfig.DefaultDependencies = "no";
      };
      suspend = {
        enable = false;
        unitConfig.DefaultDependencies = "no";
      };
      hibernate = {
        enable = false;
        unitConfig.DefaultDependencies = "no";
      };
      hybrid-sleep = {
        enable = false;
        unitConfig.DefaultDependencies = "no";
      };
    };
  };
}
