{
  description = "Hyprland setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    claude-code.url = "github:sadjow/claude-code-nix";

    gazelle.url = "github:Zeus-Deus/gazelle-tui";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      stylix,
      catppuccin,
      nixos-hardware,
      claude-code,
      gazelle,
      ...
    }:
    let
      system = "x86_64-linux";
      username = "jack";

      # Per-machine "facts" that differ
      hosts = {
        framework12 = {
          hostName = "fw12";
          internalMonitor = "eDP-1";
          scale = 1.25;
        };
      };

      mkHost =
        name: hostCfg:
        nixpkgs.lib.nixosSystem {
          inherit system;

          # Make hostCfg & username available to all modules
          specialArgs = {
            inherit
              stylix
              username
              hostCfg
              claude-code
              ;
          };

          modules = [
            stylix.nixosModules.stylix
            catppuccin.nixosModules.catppuccin
            nixos-hardware.nixosModules.framework-13th-gen-intel
            ./hosts/${name}/default.nix

            # Apply claude-code overlay and allow unfree (required for useGlobalPkgs)
            (
              { lib, ... }:
              {
                nixpkgs.overlays = [ claude-code.overlays.default ];
                nixpkgs.config.allowUnfreePredicate =
                  pkg:
                  builtins.elem (lib.getName pkg) [
                    "claude-code"
                  ];
              }
            )

            # home-manager as a NixOS module
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = {
                  imports = [
                    catppuccin.homeModules.catppuccin
                    ./users/default-user.nix
                  ];
                };
                extraSpecialArgs = {
                  inherit hostCfg username gazelle;
                };
              };
            }
          ];
        };
    in
    {
      nixosConfigurations.framework12 = mkHost "framework12" hosts.framework12;
    };
}
