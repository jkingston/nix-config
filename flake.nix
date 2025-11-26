{
  description = "Hyprland setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix/release-25.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix/v1.1.0";
  };

  outputs = { self, nixpkgs, home-manager, stylix, catppuccin, ... }:
  let
    system = "x86_64-linux";
    username = "jack";

    # Per-machine “facts” that differ
    hosts = {
      framework12 = {
        hostName = "fw12";
        internalMonitor = "eDP-1";
        scale = 1.25;
      };
    };

    mkHost = name: hostCfg:
      nixpkgs.lib.nixosSystem {
        inherit system;

        # Make hostCfg & username available to all modules
        specialArgs = {
          inherit stylix username hostCfg;
        };

        modules = [
          stylix.nixosModules.stylix
          catppuccin.nixosModules.catppuccin
          ./hosts/${name}/default.nix

          # home-manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./users/default-user.nix;
            home-manager.extraSpecialArgs = {
              inherit hostCfg username;
            };
          }
        ];
      };
  in {
    nixosConfigurations.framework12 = mkHost "framework12" hosts.framework12;
  };
}

