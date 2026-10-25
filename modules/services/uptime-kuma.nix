{
  services.uptime-kuma = {
    enable = true;
    #settings = {
    #  DATA_DIR = lib.mkForce "/data/services/uptimekuma/";
    #};
  };

  custom.services.caddy.virtualHosts."status.494203.xyz".extraConfig = ''
    reverse_proxy localhost:3001
  '';
}
