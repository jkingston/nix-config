{
  description = "Hyprland setup";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gazelle.url = "github:Zeus-Deus/gazelle-tui";
  };

  outputs =
    {
      determinate,
      nixpkgs,
      home-manager,
      stylix,
      nixos-hardware,
      disko,
      gazelle,
      ...
    }:
    let
      username = "jack";

      # Load profile and convert to hostCfg format (backward compatibility)
      loadProfile =
        name: profilePath:
        let
          # Some profiles need inputs (e.g., nixos-hardware)
          rawProfile = import profilePath;
          profile =
            if builtins.isFunction rawProfile then rawProfile { inherit nixos-hardware; } else rawProfile;
        in
        {
          system = profile.system;
          hostName = profile.hostName;
          internalMonitor = profile.monitor.name;
          scale = profile.monitor.scale;
          isLaptop = profile.isLaptop;
          isVM = profile.isVM or false;
          gaps = profile.gaps or { };
          hardwareModules = profile.hardwareModules;
          extraModules = profile.extraModules;
        };

      mkHost =
        name: profilePath:
        let
          hostCfg = loadProfile name profilePath;
          # Ensure isVM has a default
          hostCfg' = {
            isVM = false;
          }
          // hostCfg;
        in
        nixpkgs.lib.nixosSystem {
          inherit (hostCfg') system;

          # Make hostCfg & username available to all modules
          specialArgs = {
            inherit stylix username;
            hostCfg = hostCfg';
          };

          modules = [
            determinate.nixosModules.default
            stylix.nixosModules.stylix
            disko.nixosModules.disko
            ./hosts/${name}/default.nix

            # home-manager as a NixOS module
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = {
                  imports = [
                    ./users/default-user.nix
                  ];
                };
                extraSpecialArgs = {
                  hostCfg = hostCfg';
                  inherit username gazelle;
                };
              };
            }
          ]
          ++ hostCfg'.hardwareModules
          ++ hostCfg'.extraModules;
        };
    in
    {
      nixosConfigurations.framework12 = mkHost "framework12" ./hosts/framework12/profile.nix;
      nixosConfigurations.vm-aarch64 = mkHost "vm-aarch64" ./hosts/vm-aarch64/profile.nix;
      nixosConfigurations.minipc = mkHost "minipc" ./hosts/minipc/profile.nix;
    };
}
