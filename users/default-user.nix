{ config, pkgs, lib, hostCfg, username, ... }:

let
  scaleStr = builtins.toString hostCfg.scale;
  monitorName = hostCfg.internalMonitor;
in {
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";

  # Catppuccin - primary theming for home-manager apps
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";

    # Disable mako - the catppuccin module uses deprecated extraConfig API
    # Colors are applied directly in modules/home/ui.nix instead
    mako.enable = false;
  };

  # Catppuccin cursors (configured via home.pointerCursor since catppuccin.cursors
  # doesn't exist in catppuccin/nix v1.1.0)
  home.pointerCursor = {
    name = "catppuccin-mocha-blue-cursors";
    package = pkgs.catppuccin-cursors.mochaBlue;
    size = 24;
    gtk.enable = true;
  };

  ########################
  ## Display profile (per-host via hostCfg)
  ########################

  home.sessionVariables = {
    GDK_SCALE = "1";
    GDK_DPI_SCALE = scaleStr;
    QT_AUTO_SCREEN_SCALE_FACTOR = "0";
    QT_SCALE_FACTOR = scaleStr;
  };

  gtk = {
    enable = true;

    gtk3.extraConfig =
      let
        dpi = 96.0 * hostCfg.scale * 1000.0;
      in {
        "gtk-xft-dpi" = builtins.toString (builtins.floor dpi);
      };

    gtk4.extraConfig = config.gtk.gtk3.extraConfig;
  };

  ########################
  ## Shared UI / tools
  ########################

  imports = [
    ../modules/home/ui.nix
    ../modules/home/dev.nix
    ../modules/home/shell.nix
  ];
}

