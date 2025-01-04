{
  services.immich = {
    enable = true;
    port = 2283;
    mediaLocation = "/data/media/immich";
    environment.IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
  };

  custom.services.caddy.virtualHosts."photos.494203.xyz".extraConfig = ''
    reverse_proxy http://localhost:2283
  '';
  users.users.immich.extraGroups = [
    "video"
    "render"
  ];
}
