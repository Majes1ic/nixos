{
  boot = {
    loader.efi.canTouchEfiVariables = true;

    loader.systemd-boot = {
      enable = true;
      consoleMode = "max";
      configurationLimit = 20;
    };
  };

  # Use compressed RAM for swap
  zramSwap.enable = true;

  services.zfs = {
    trim.enable = true;
    autoScrub.enable = true;
  };
}
