# Common NixOS configuration - imports split system modules
{
  pkgs,
  lib,
  hostCfg,
  username,
  stylix,
  ...
}:

{
  imports = [
    ../system/core.nix
    ../system/greetd.nix
    ../system/pipewire.nix
    ../system/power.nix
    ../system/stylix.nix
  ];

  # libinput for touchpad/mouse
  services.libinput.enable = true;
}
