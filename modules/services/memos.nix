{
  services.memos = {
    enable = true;
  };

  custom.services.caddy.virtualHosts."notes.494203.xyz".extraConfig = ''
    reverse_proxy http://localhost:5230
  '';

  networking.firewall.interfaces."enp34s0".allowedTCPPorts = [ 5230 ];
  networking.firewall.interfaces."wg-home".allowedTCPPorts = [ 5230 ];
  networking.firewall.interfaces."wg-discord".allowedTCPPorts = [ 5230 ];
}
