# Machine-specific configuration for framework12 (Framework 13 laptop)
{ nixos-hardware }:
{
  # Hardware identity
  system = "x86_64-linux";
  hostName = "fw12";
  isLaptop = true;
  isVM = false;

  # Display configuration
  monitor = {
    name = "eDP-1";
    scale = 1.25;
  };

  # Hardware modules (NixOS level)
  hardwareModules = [
    nixos-hardware.nixosModules.framework-13th-gen-intel
    ../../modules/system/hardware/intel-graphics.nix
  ];

  # Extra NixOS modules
  extraModules = [ ];
}
