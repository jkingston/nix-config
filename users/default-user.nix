{
  pkgs,
  lib,
  hostCfg,
  username,
  gazelle,
  ...
}:

{
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
    sessionPath = [ "$HOME/.local/bin" ];

    # Adwaita cursor (Omarchy default)
    pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
      gtk.enable = true;
      hyprcursor = {
        enable = true;
        size = 24;
      };
    };
  };

  # Dark mode preference (enables prefers-color-scheme: dark in browsers)
  # Use mkForce to override Stylix's default
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = lib.mkForce "prefer-dark";
      };
    };
  };

  gtk = {
    enable = true;
  };

  imports = [
    gazelle.homeModules.gazelle
    ../modules/desktop/xdg-portal.nix
    ../modules/desktop/hyprland.nix
    ../modules/desktop/waybar.nix
    ../modules/desktop/rofi.nix
    ../modules/desktop/mako.nix
    ../modules/desktop/hyprlock.nix
    ../modules/desktop/hypridle.nix
    ../modules/desktop/nightlight.nix
    ../modules/desktop/wallpaper.nix
    ../modules/desktop/clipboard.nix
    ../modules/desktop/scripts.nix
    ../modules/desktop/packages.nix
    ../modules/desktop/chromium.nix
    ../modules/desktop/ghostty.nix
    ../modules/home/dev.nix
    ../modules/home/shell.nix
  ];
}
