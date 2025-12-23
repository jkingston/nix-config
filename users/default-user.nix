{
  config,
  pkgs,
  hostCfg,
  username,
  gazelle,
  ...
}:

let
  scaleStr = builtins.toString hostCfg.scale;
in
{
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";

    sessionVariables = {
      GDK_SCALE = "1";
      GDK_DPI_SCALE = scaleStr;
      QT_AUTO_SCREEN_SCALE_FACTOR = "0";
      QT_SCALE_FACTOR = scaleStr;
    };

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

  gtk = {
    enable = true;

    gtk3.extraConfig =
      let
        dpi = 96.0 * hostCfg.scale * 1000.0;
      in
      {
        "gtk-xft-dpi" = builtins.toString (builtins.floor dpi);
      };

    gtk4.extraConfig = config.gtk.gtk3.extraConfig;
  };

  imports = [
    gazelle.homeModules.gazelle
    ../modules/home/ui.nix
    ../modules/home/dev.nix
    ../modules/home/shell.nix
  ];
}
