# Stylix configuration - wallpaper and fonts (catppuccin handles colors)
{ pkgs, ... }:

{
  stylix = {
    enable = true;
    autoEnable = false; # Don't auto-theme apps - catppuccin does that

    # Color scheme still needed for Stylix internals
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    # Wallpaper (catppuccin/nix doesn't handle this)
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/forrest.png";
      sha256 = "sha256-jDqDj56e9KI/xgEIcESkpnpJUBo6zJiAq1AkDQwcHQM=";
    };

    # Fonts (catppuccin/nix doesn't handle this)
    fonts.monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
    };

    overlays.enable = false;
  };
}
