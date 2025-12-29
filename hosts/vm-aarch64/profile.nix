# Machine-specific configuration for vm-aarch64 (UTM VM on Apple Silicon)
{
  # Hardware identity
  system = "aarch64-linux";
  hostName = "vm";
  isLaptop = false;
  isVM = true;

  # Display configuration
  monitor = {
    name = "Virtual-1";
    scale = 1.0;
  };

  # Hardware modules (NixOS level)
  hardwareModules = [ ];

  # Extra NixOS modules
  extraModules = [ ];
}
