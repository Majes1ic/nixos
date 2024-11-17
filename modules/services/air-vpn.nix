{ inputs, ... }:
{
  import = [ inputs.vpn-confinement.nixosModules.default ];

  vpnNamespaces.air-vpn = {
    enable = true;
    wireguardConfigFile = "/etc/wireguard/AirVPN_Swiss_Homelab.conf";
    accessibleFrom = [ "127.0.0.1" ];
  };
}
