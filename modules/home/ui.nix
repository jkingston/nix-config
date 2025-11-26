{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ];

  home = {
    packages = with pkgs; [
      # Core UI tools
      ghostty
      anyrun
      waybar
      mako
      hyprlock
      wvkbd
      cliphist
      localsend

      # Browser / misc
      chromium
    ];

    file.".local/bin/osk-toggle" = {
      text = ''
        #!/usr/bin/env bash
        if pgrep -x wvkbd-mobintl >/dev/null; then
          pkill -x wvkbd-mobintl
        else
          wvkbd-mobintl --landscape --opacity 0.98 --rounding 10 --hidden &
        fi
      '';
      executable = true;
    };

    file.".local/bin/anyrun-clipboard" = {
      text = ''
        #!/usr/bin/env bash
        cliphist list \
          | anyrun --plugins libstdin.so \
          | cliphist decode \
          | wl-copy
      '';
      executable = true;
    };
  };

  ########################################
  ## Hyprland (shared settings)
  ########################################

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    package = null;
    portalPackage = null;

    # Scaling & monitor layout are passed in from host via users/default-user.nix,
    # so only the SHARED config goes here.
    settings = {
      input = {
        kb_layout = "gb";

        touchpad = {
          natural_scroll = true;
        };
      };

      "$mod" = "SUPER";

      exec-once = [
        "mako"
      ];

      # Keybinds that do NOT depend on monitors
      bind = [
        "$mod, RETURN, exec, ghostty"
        "$mod, SPACE, exec, anyrun"
        "$mod, Q, killactive,"
        "$mod, L, exec, hyprlock"

        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"

        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, L, movewindow, r"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"

        # Clipboard picker
        "$mod, S, exec, ~/.local/bin/anyrun-clipboard"

        # OSK
        "$mod, O, exec, ~/.local/bin/osk-toggle"
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

  ########################################
  ## Ghostty terminal
  ########################################

  xdg.configFile."ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    font-size = 11
    theme = catppuccin-mocha

    window-decoration = none
    window-padding-x = 8
    window-padding-y = 8
  '';

  ########################################
  ## Programs (anyrun, waybar, hyprlock)
  ########################################

  programs = {
    anyrun = {
      enable = true;

      config = {
        # Center position
        x = {
          fraction = 0.5;
        };
        y = {
          fraction = 0.25;
        };
        width = {
          fraction = 0.38;
        };

        hideIcons = false;
        ignoreExclusiveZones = false;
        layer = "overlay";
        hidePluginInfo = false;
        closeOnClick = true;
        showResultsImmediately = true;

        plugins = [
          "${pkgs.anyrun}/lib/libapplications.so"
          "${pkgs.anyrun}/lib/libsymbols.so"
          "${pkgs.anyrun}/lib/libwebsearch.so"
          "${pkgs.anyrun}/lib/libstdin.so"
          "${pkgs.anyrun}/lib/librink.so"
          "${pkgs.anyrun}/lib/libkidex.so"
          "${pkgs.anyrun}/lib/libshell.so"
        ];
      };

      extraCss = ''
        window { background-color: transparent; }

        .main {
          background-color: rgba(17, 17, 27, 0.94);
          border-radius: 18px;
          padding: 12px;
        }

        entry, textview {
          background: rgba(24, 24, 37, 0.9);
          border-radius: 12px;
          padding: 8px 10px;
          font-size: 14pt;
          color: #cdd6f4;
        }

        .matches {
          margin-top: 6px;
          gap: 4px;
        }

        .match {
          padding: 6px 8px;
          border-radius: 10px;
        }

        .match:selected {
          background: rgba(137, 180, 250, 0.22);
        }
      '';

      extraConfigFiles = {
        "applications.ron".text = ''
          Config(
            desktop_actions: true,
            max_entries: 8,
            terminal: Some("ghostty"),
          )
        '';

        "symbols.ron".text = ''
          Config(
            prefix: ":",
            max_entries: 10,
          )
        '';

        "websearch.ron".text = ''
          Config(
            prefix: "?",
            engines: [DuckDuckGo],
          )
        '';

        "shell.ron".text = ''
          Config(
            prefix: ":sh",
            shell: None,
          )
        '';

        "kidex.ron".text = ''
          Config(
            max_entries: 10,
          )
        '';
      };
    };

    waybar = {
      enable = true;
      settings.mainBar = {
        layer = "top";
        height = 32;
        position = "top";

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [
          "pulseaudio"
          "battery"
          "network"
          "tray"
        ];
      };
    };

    hyprlock.enable = true;
  };

  ########################################
  ## Mako notifications
  ########################################

  services.mako = {
    enable = true;
    # Catppuccin colors applied automatically via catppuccin module
    settings = {
      padding = "10,20,10,20";
      default-timeout = 5000;
      border-radius = 10;
    };
  };
}
