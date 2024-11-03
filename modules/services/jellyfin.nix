{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  virtualHosts."jellyfin.494203.xyz ".extraConfig = ''
    reverse_proxy http://localhost:8096
  '';
}
