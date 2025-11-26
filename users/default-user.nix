{
  config,
  pkgs,
  lib,
  hostCfg,
  username,
  ...
}:

let
  scaleStr = builtins.toString hostCfg.scale;
  monitorName = hostCfg.internalMonitor;
in
{
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";

    sessionVariables = {
      GDK_SCALE = "1";
      GDK_DPI_SCALE = scaleStr;
      QT_AUTO_SCREEN_SCALE_FACTOR = "0";
      QT_SCALE_FACTOR = scaleStr;
    };
  };

  # Catppuccin - primary theming for home-manager apps
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";

    cursors = {
      enable = true;
      accent = "blue";
    };
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
    ../modules/home/ui.nix
    ../modules/home/dev.nix
    ../modules/home/shell.nix
  ];
}
