{ pkgs, ... }:
{
  services.unifi = {
    enable = true;
    openFirewall = true;
    unifiPackage = pkgs.unifi;
    mongodbPackage = pkgs.mongodb-7_0;
    jrePackage = pkgs.jdk17_headless;
  };

  networking.firewall.interfaces."enp43s0".allowedTCPPorts = [ 8443 ];
  networking.firewall = {
    # https://help.ubnt.com/hc/en-us/articles/218506997
    allowedTCPPorts = [
      8080 # Device communication
      6789 # UniFi mobile speed test
    ];
    allowedUDPPorts = [
      10001 # Device discovery
    ];
  };

  custom.services.caddy.virtualHosts."unifi.494203.xyz".extraConfig = ''
    reverse_proxy https://localhost:8443 {
      transport http {
        tls
        tls_insecure_skip_verify
      }
    }
  '';
}
