# Rofi app launcher and power menu
{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi; # rofi-wayland was merged into rofi
    terminal = "${pkgs.ghostty}/bin/ghostty";
    plugins = with pkgs; [
      rofi-calc
    ];
    extraConfig = {
      modi = "drun,run,calc";
      show-icons = true;
      drun-display-format = "{name}";
    };
  };

  home.packages = with pkgs; [
    rofi-power-menu # power menu script
    rofimoji # emoji picker (standalone, uses rofi)
  ];

  # Clipboard picker script
  home.file.".local/bin/rofi-clipboard" = {
    text = ''
      #!/usr/bin/env bash
      cliphist list | rofi -dmenu -p "Clipboard" | cliphist decode | wl-copy
    '';
    executable = true;
  };
}
