# This requires rlcraft server to be available to run in /var/lib/minecraft/rlcraft, and owned by minecraft:minecraft.

{ pkgs, ... }:

{
  users.groups.minecraft = { };
  users.users.minecraft = {
    isSystemUser = true;
    group = "minecraft";
    home = "/var/lib/minecraft";
  };

  systemd.services.minecraft-rlcraft = {
    #disabling for now as I am playing gregcraft
    enable = false;
    description = "RLCraft Minecraft Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      WorkingDirectory = "/data/services/minecraft/rlcraft";
      ExecStart = "${pkgs.jdk8_headless}/bin/java -Xms6G -Xmx14G -jar forge-1.12.2-14.23.5.2860.jar nogui";
      User = "minecraft";
      Restart = "on-failure";
    };
  };

  systemd.services.minecraft-gregtech = {
    enable = false;
    description = "Gregtech Minecraft Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      WorkingDirectory = "/data/services/minecraft/gregtech";
      ExecStart = "${pkgs.jdk25_headless}/bin/java -Xms6G -Xmx8G @java9args.txt -jar lwjgl3ify-forgePatches.jar nogui";
      User = "minecraft";
      Restart = "on-failure";
      MemoryHigh = "10G";
      MemoryMax = "12G";
    };
  };

  # opening minecraft port for friends
  networking.firewall.interfaces."wg-discord".allowedTCPPorts = [ 25565 ];

  # below doesn't work as MC a TCP connection, which Caddy cannot handle
  #custom.services.caddy.virtualHosts."rlcraft.494203.xyz".extraConfig = ''
  #  reverse_proxy http://localhost:25565
  #'';
}
