{ inputs, ... }:
{
  imports = [ inputs.vpn-confinement.nixosModules.default ];

  vpnNamespaces.air-vpn = {
    enable = true;
    wireguardConfigFile = "/etc/wireguard/AirVPN_Swiss_Homelab.conf";
    accessibleFrom = [ "127.0.0.1" ];
    namespaceAddress = "192.168.15.1";
  };
}
