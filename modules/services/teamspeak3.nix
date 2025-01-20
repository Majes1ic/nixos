{ config, lib, ... }:
{
  services.teamspeak3 = {
    enable = true;
    openFirewall = false;
    voiceIP = "10.0.0.9";
    queryIP = "10.0.0.9";
    fileTransferIP = "10.0.0.9";
  };

  networking.firewall.interfaces."wg-discord" = {
    allowedTCPPorts =
      [ config.services.teamspeak3.fileTransferPort ]
      ++ (map (port: lib.mkIf config.services.teamspeak3.openFirewallServerQuery port) [
        config.services.teamspeak3.queryPort
        config.services.teamspeak3.querySshPort
        config.services.teamspeak3.queryHttpPort
      ]);
    # subsequent vServers will use the incremented voice port, let's just open the next 10
    allowedUDPPortRanges = [
      {
        from = config.services.teamspeak3.defaultVoicePort;
        to = config.services.teamspeak3.defaultVoicePort + 10;
      }
    ];
  };
}
