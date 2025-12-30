# Rofi app launcher and power menu
{ pkgs, config, ... }:

let
  inherit (config.lib.formats.rasi) mkLiteral;
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "${pkgs.ghostty}/bin/ghostty";
    plugins = with pkgs; [
      rofi-calc
    ];
    extraConfig = {
      modi = "drun,run,calc";
      show-icons = true;
      drun-display-format = "{name}";
      icon-theme = "Adwaita";
    };

    # Omarchy Minimal theme - square corners, Stylix colors
    theme = {
      window = {
        width = mkLiteral "600px";
        border = mkLiteral "2px";
        border-radius = mkLiteral "0px";
        padding = mkLiteral "20px";
      };
      mainbox = {
        spacing = mkLiteral "10px";
      };
      inputbar = {
        padding = mkLiteral "10px";
        border-radius = mkLiteral "0px";
      };
      listview = {
        lines = 8;
        spacing = mkLiteral "5px";
      };
      element = {
        padding = mkLiteral "10px";
        border-radius = mkLiteral "0px";
      };
      element-icon = {
        size = mkLiteral "24px";
      };
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
