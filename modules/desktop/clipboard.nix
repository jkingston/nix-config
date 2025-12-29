# Clipboard management with cliphist
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cliphist
    wl-clipboard
  ];

  # Note: cliphist is started via Hyprland exec-once:
  # wl-paste --watch cliphist store
  # wl-paste --type image --watch cliphist store
}
