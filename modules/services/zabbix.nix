{
  services.zabbixWeb = {
    enable = true;
    hostname = "zabbix.494203.xyz";
  };

  services.zabbixServer = {
    enable = true;
    openFirewall = true;
  };

  services.zabbixAgent = {
    enable = true;
    openFirewall = true;
    server = "homelab.lan";
  };

  custom.services.caddy.virtualHosts."zabbix.494203.xyz" = {
    extraConfig = ''
      root * /var/lib/zabbix/www
      php_fastcgi unix//run/phpfpm/zabbix.sock
      file_server
    '';
  };

  networking.firewall.interfaces.enp43s0.allowedTCPPortRanges = [
    {
      from = 10050;
      to = 10051;
    }
  ];
}
