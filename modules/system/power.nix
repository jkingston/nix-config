# Laptop power management - upower, power profiles, lid switch handling
{
  pkgs,
  lib,
  hostCfg,
  ...
}:

{
  services = {
    upower.enable = hostCfg.isLaptop;
    dbus.packages = lib.mkIf hostCfg.isLaptop [ pkgs.iio-sensor-proxy ];

    # Let Hyprland handle lid switch (don't let systemd intercept it)
    logind = lib.mkIf hostCfg.isLaptop {
      lidSwitch = "ignore";
      lidSwitchExternalPower = "ignore";
      lidSwitchDocked = "ignore";
    };

    # Laptop-specific services
    power-profiles-daemon.enable = hostCfg.isLaptop;
    fwupd.enable = hostCfg.isLaptop;
  };
}
