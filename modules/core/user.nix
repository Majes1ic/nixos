{
  lib,
  pkgs,
  username,
  config,
  ...
}:
{
  users = {
    mutableUsers = false;
    users = {
      ${username} = {
        isNormalUser = true;
        shell = pkgs.zsh;
        hashedPasswordFile = config.age.secrets.usrPass.path;
        extraGroups = [ "wheel" ];
      };
      #joshua = {
      #  isNormalUser = true;
      #  createHome = true;
      #  packages = [ pkgs.zellij ];
      #};
    };
  };
  age.secrets.usrPass.file = ../../secrets/usrPass.age;

  virtualisation.vmVariant = {
    users.users.${username} = {
      password = "test";
      hashedPasswordFile = lib.mkVMOverride null;
    };
  };
}
