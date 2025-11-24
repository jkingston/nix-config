{ config, pkgs, lib, hostCfg, username, ... }:

let
  scaleStr = builtins.toString hostCfg.scale;
  monitorName = hostCfg.internalMonitor;
in {
  home.username = jack;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";

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
    gtk3.extraConfig = {
      "gtk-xft-dpi" =
        let dpi = 96.0 * hostCfg.scale * 1000.0;
        in toString (builtins.floor dpi);
    };
    gtk4.extraConfig = gtk.gtk3.extraConfig;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = [
        "${monitorName},preferred,auto,${scaleStr}"
      ];

      "$mod" = "SUPER";
      exec-once = [ "waybar" "mako" ];

      bind = [
        "$mod, RETURN, exec, ghostty"
        "$mod, SPACE,  exec, anyrun"
        "$mod, Q,      killactive,"
        "$mod, L,      exec, hyprlock"
        "$mod, O,      exec, ~/.local/bin/osk-toggle"
        "$mod, S,      exec, ~/.local/bin/anyrun-clipboard"

        "$mod, H,      movefocus, l"
        "$mod, J,      movefocus, d"
        "$mod, K,      movefocus, u"
        "$mod, L,      movefocus, r"

        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, L, movewindow, r"
      ];

      general = {
        gaps_in = 8;
        gaps_out = 16;
        border_size = 2;
      };

      decoration = {
        rounding = 12;
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
        };
      };
    };
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

