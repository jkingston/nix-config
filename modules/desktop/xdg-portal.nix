# XDG Portal configuration for dark mode detection and Hyprland integration
{
  pkgs,
  lib,
  ...
}:

{
  xdg.portal = {
    enable = lib.mkForce true; # Override Hyprland module's default
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.common = {
      default = [
        "hyprland"
        "gtk"
      ];
      # GTK portal provides dark mode setting to browsers
      "org.freedesktop.impl.portal.Settings" = "gtk";
    };
  };
}
