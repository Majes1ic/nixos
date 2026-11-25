let
  maximum = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILXXsn0Q4UzpMAnYa5b2TE5KxTeBjLy0ck4eIwekD93b root@maximum";
  homelab = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBrHg11XOCtV+oktl/erPg4VrmOohP0WksQiJqGKwQ0C root@homelab";
  zbook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOnsTpx3A7NYrbejAJXfXsQ6qo5d9mD9HB5sfC0VgOSM root@zbook";

in
{
  "usrPass.age".publicKeys = [
    maximum
    homelab
    zbook
  ];
  "porkbunVars.age".publicKeys = [
    homelab
  ];
}
