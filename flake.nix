{
  description = "Tom's NixOS Flake";

  inputs = {
    # NOTE: Use the `nix flake metadata <flake_url>` command to check if a
    # flake needs nixpkgs.follows defined
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #    hyprland = {
    #      url = "github:hyprwm/Hyprland";
    #      inputs.nixpkgs.follows = "nixpkgs";
    #    };

    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      username = "tom";
    in
    {
      nixosConfigurations = {
        maximum = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit self inputs username;
            hostname = "maximum";
          };
          modules = [
            # this is the same as ./hosts/maximum/default.nix
            ./hosts/maximum
          ];
        };

        homelab = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit self inputs username;
            hostname = "homelab";
          };
          modules = [ ./hosts/homelab ];
        };

        zbook = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit self inputs username;
            hostname = "zbook";
          };
          modules = [ ./hosts/zbook ];
        };
      };

      packages.x86_64-linux.installer =
        (nixpkgs.lib.nixosSystem {
          stdenv.hostPlatform.system = "x86_64-linux";
          modules = [ ./hosts/installer.nix ];
        }).config.system.build.isoImage;

      homeConfigurations = {
        "${username}@mac" = home-manager.lib.homeManagerConfiguration {
          modules = [ ./home/mac.nix ];
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit self inputs username;
          };
        };
      };
    };

  # A flake has inputs and outputs
  # Inputs are mostly other flakes, but that can be non-flakes (rare though)
  # Outputs is what your flake produces
  # There is an "output schema" which flakes generally adhere to
}
