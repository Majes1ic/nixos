{
  custom.services.caddy.virtualHosts."http://minesweeper.494203.xyz".extraConfig = ''
    encode zstd gzip
    file_server
    try_files {path} /index.html
    root * /srv/coop_minesweeper
  '';
}
