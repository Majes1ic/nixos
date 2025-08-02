{
  services.prometheus = {
    enable = true;
    exporters.blackbox = {
      enable = true;
      configFile = ./blackbox.yml;
    };
    scrapeConfigs = [
      {
        job_name = "homelab";
        static_configs = [
          {
            targets = [ "192.168.88.253:9100" ];
          }
        ];
      }

      {
        job_name = "blackbox_http";
        metrics_path = "/probe";
        params.module = [ "http_2xx" ];
        static_configs = [
          {
            targets = [ "http://192.168.54.10:8096" ]; # Jellyfin
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "localhost:9115"; # Blackbox exporter on same host
          }
        ];
      }
      {
        job_name = "blackbox_tcp";
        metrics_path = "/probe";
        params.module = [ "tcp_connect" ];
        static_configs = [
          {
            targets = [ "192.168.54.20:25565" ]; # Minecraft
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "localhost:9115";
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
