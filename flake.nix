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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      disko,
      claude-code,
      gazelle,
      ...
    }:
    let
      username = "jack";

      # Per-machine "facts" that differ
      hosts = {
        framework12 = {
          system = "x86_64-linux";
          hostName = "fw12";
          internalMonitor = "eDP-1";
          scale = 1.25;
          isLaptop = true;
          hardwareModules = [ nixos-hardware.nixosModules.framework-13th-gen-intel ];
          extraModules = [ ./modules/nixos/hardware/intel-graphics.nix ];
        };
        vm-aarch64 = {
          system = "aarch64-linux";
          hostName = "vm";
          internalMonitor = "Virtual-1";
          scale = 1.0;
          isLaptop = false;
          hardwareModules = [ ];
          extraModules = [ ];
        };
        minipc = {
          system = "x86_64-linux";
          hostName = "minipc";
          internalMonitor = "HDMI-A-1";
          scale = 1.0;
          isLaptop = false;
          hardwareModules = [ ];
          extraModules = [ ./modules/nixos/hardware/amd-graphics.nix ];
        };
      };

      mkHost =
        name: hostCfg:
        nixpkgs.lib.nixosSystem {
          system = hostCfg.system;

          # Make hostCfg & username available to all modules
          specialArgs = {
            inherit
              stylix
              username
              hostCfg
              claude-code
              ;
          };

          modules =
            [
              stylix.nixosModules.stylix
              catppuccin.nixosModules.catppuccin
              disko.nixosModules.disko
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
            ]
            ++ hostCfg.hardwareModules
            ++ hostCfg.extraModules;
        };
    in
    {
      nixosConfigurations.framework12 = mkHost "framework12" hosts.framework12;
      nixosConfigurations.vm-aarch64 = mkHost "vm-aarch64" hosts.vm-aarch64;
      nixosConfigurations.minipc = mkHost "minipc" hosts.minipc;
    };
}
