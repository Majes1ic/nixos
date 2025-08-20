{
  # Enable the File Browser service
  services.filebrowser = {
    enable = true;
    user = "filebrowser";
    group = "filebrowser";
    openFirewall = false; # We're proxying via Caddy

    settings = {
      root = "/srv/caddyfileserver";
      port = 8099;
    };
  };

  # Ensure the directory exists and is writable
  systemd.tmpfiles.rules = [
    "d /srv/caddyfileserver 0755 filebrowser filebrowser -"
    "d /var/cache/filebrowser 0755 filebrowser filebrowser -"
  ];

  custom.services.caddy.virtualHosts."files.494203.xyz".extraConfig = ''
    reverse_proxy http://localhost:8099
  '';
}
