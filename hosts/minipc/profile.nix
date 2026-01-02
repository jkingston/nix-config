# Machine-specific configuration for minipc (Beelink SER5 Pro)
{
  # Hardware identity
  system = "x86_64-linux";
  hostName = "minipc";
  isLaptop = false;
  isVM = false;

  # Display configuration
  monitor = {
    name = ""; # Wildcard - applies to all monitors
    scale = 1.66666666;
  };

  # Window gaps and borders
  gaps = {
    inner = 5;
    outer = 10;
  };

  # Hardware modules (NixOS level)
  hardwareModules = [
    ../../modules/system/hardware/amd-graphics.nix
  ];

  # Extra NixOS modules
  extraModules = [ ];
}
