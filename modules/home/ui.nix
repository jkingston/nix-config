# Desktop UI configuration - imports split desktop modules
{
  config,
  pkgs,
  lib,
  hostCfg,
  gazelle,
  ...
}:

{
  imports = [
    ../desktop/xdg-portal.nix
    ../desktop/hyprland.nix
    ../desktop/waybar.nix
    ../desktop/walker.nix
    ../desktop/mako.nix
    ../desktop/hyprlock.nix
    ../desktop/wlogout.nix
    ../desktop/hypridle.nix
    ../desktop/nightlight.nix
    ../desktop/wallpaper.nix
    ../desktop/clipboard.nix
    ../desktop/scripts.nix
    ../desktop/packages.nix
    ../desktop/chromium.nix
    ../desktop/ghostty.nix
  ];
}
