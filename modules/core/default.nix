{
  imports = [
    ./age.nix
    ./file-system.nix
    ./home-manager.nix
    ./nix.nix
    ./user.nix
  ];

  programs.zsh.enable = true;

  time.timeZone = "Europe/London";
}
