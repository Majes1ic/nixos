{ username, ... }:
{
  services.openssh = {
    enable = true;
    openFirewall = true;

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = [
        username
        "root"
      ];
    };

    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  programs.ssh.startAgent = true;

  networking.firewall.interfaces = {
    # wg-discord.allowedTCPPorts = [ 22 ];
    wg-home.allowedTCPPorts = [ 22 ];
  };

  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHZ6ElOfDAOSAuRKSh8TOGmg9QQFbb1YLz5nRNZYCFqL one"
  ];
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPcz8AAM0lFLJU3xNTaAOpK9HX/oDR92jC5tPOdpKsbh homelab-rootkey"
  ];
}
