{
  pkgs,
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

    # XWayland DPI scaling (96 * scale factor)
    # This is loaded by xrdb in Hyprland exec-once
    file.".Xresources".text = ''
      Xft.dpi: ${builtins.toString (builtins.floor (96.0 * hostCfg.scale))}
      Xft.autohint: 0
      Xft.lcdfilter: lcddefault
      Xft.hintstyle: hintfull
      Xft.hinting: 1
      Xft.antialias: 1
      Xft.rgba: rgb
    '';

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

  # Catppuccin - primary theming for home-manager apps
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
    mako.enable = true;
    waybar.enable = false; # Using custom Omarchy styling
    bat.enable = true;
    fzf.enable = true;
    hyprlock.enable = false; # Using custom Omarchy styling
    wlogout.enable = true;
    ghostty.enable = true;
  };

  # Dark mode preference (enables prefers-color-scheme: dark in browsers)
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
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
    ../modules/desktop/walker.nix
    ../modules/desktop/mako.nix
    ../modules/desktop/hyprlock.nix
    ../modules/desktop/wlogout.nix
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
