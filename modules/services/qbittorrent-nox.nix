{
  config,
  pkgs,
  lib,
  username,
  ...
}:
let
  port = 8087;
in
{
  users.groups.qbittorrent-nox = { };
  users.users.qbittorrent-nox = {
    group = "qbittorrent-nox";
    isSystemUser = true;
  };

  users.users.${username}.extraGroups = [ "qbittorrent-nox" ];
  systemd.services.qbittorrent-nox = {
    description = "qBittorrent-nox";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    environment = {
      QBT_PROFILE = "/var/lib/qbittorrent-nox";
      QBT_WEBUI_PORT = toString port;
    };

    vpnConfinement = {
      vpnNamespace = "air-vpn";
      enable = true;
    };

    serviceConfig = {
      DynamicUser = false;
      User = "qbittorrent-nox";
      Group = "qbittorrent-nox";
      UMask = "0022";
      StateDirectory = "qbittorrent-nox";
      StateDirectoryMode = "750";
      ExecStart = lib.getExe' pkgs.qbittorrent-nox "qbittorrent-nox";
      Restart = "always";
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      LockPersonality = true;
      NoNewPrivileges = true;
      PrivateUsers = true; # has to be false for CAP_NET_BIND_SERVICE
      PrivateDevices = true;
      PrivateMounts = true;
      PrivateTmp = true;
      ProtectSystem = "strict"; # does not apply to service directories like StateDirectory
      ReadWritePaths = "/data/media/torrents";
      ProtectHome = true;
      ProtectControlGroups = true;
      ProtectClock = true;
      ProtectProc = "invisible";
      ProcSubset = "pid";
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RemoveIPC = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
        "~@resources"
      ];
      CapabilityBoundingSet = "";
      AmbientCapabilities = "";
      DeviceAllow = "";
      MemoryDenyWriteExecute = true;
    };

    wantedBy = [ "multi-user.target" ];
  };

  systemd.tmpfiles.rules = [
    "d /data/torrents 0755 qbittorrent-nox qbittorrent-nox - -"
  ];

  vpnNamespaces.air-vpn = {
    portMappings = [
      {
        from = port;
        to = port;
      }
    ];
    openVPNPorts = [
      {
        #public port for VPN can configure on air-vpn site
        port = 36780;
        protocol = "both";
      }
    ];
  };
  custom.services.caddy.virtualHosts."torrent.494203.xyz".extraConfig = ''
    reverse_proxy http://${config.vpnNamespaces.air-vpn.namespaceAddress}:${toString port}
  '';
}
