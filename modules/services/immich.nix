{
  services.immich = {
    enable = true;
    port = 2283;
    mediaLocation = "/data/media/immich";
    environment.IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
    machine-learning.enable = false;
  };

  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:...your key here..."
  ];

  custom.services.caddy.virtualHosts."photos.494203.xyz".extraConfig = ''
    @block {
      not remote_ip 192.168.88.0/24 10.0.1.0/24
    }
    respond @block "Access denied" 403 {
      close
    }
    reverse_proxy http://localhost:2283
  '';

  users.users.immich.extraGroups = [
    "video"
    "render"
  ];
}
