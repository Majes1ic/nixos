{
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "homelab";
        static_configs = [
          {
            targets = [ "192.168.88.253:9100" ];
          }
        ];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
      };
    };
  };

  custom.services.caddy.virtualHosts."monitoring.494203.xyz".extraConfig = ''
    reverse_proxy http://localhost:3000
  '';
}
