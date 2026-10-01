{
  services.trilium-server = {
    enable = true;
    port = 7901;
  };

  custom.services.caddy.virtualHosts."notes2.494203.xyz".extraConfig = ''
    reverse_proxy localhost:7901
  '';
}
