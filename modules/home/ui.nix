{
  config,
  pkgs,
  walker,
  ...
}:

{
  imports = [ ];

  home = {
    packages = with pkgs; [
      # Core UI tools
      ghostty
      hyprlock
      wvkbd
      cliphist
      wl-clipboard
      localsend

      # HyprPanel dependencies
      libgtop # for resource monitor
      bluez # for bluetooth
      grimblast # for screenshots
      gpu-screen-recorder # for screen recording
      hyprpicker # for color picker
      hyprsunset # for blue light filter
      btop # for dashboard stats

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

    file.".local/bin/walker-clipboard" = {
      text = ''
        #!/usr/bin/env bash
        cliphist list \
          | walker --dmenu \
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
          clickfinger_behavior = true;
          tap-to-click = true;
        };
      };

      # Touchpad gestures
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_distance = 300;
        workspace_swipe_cancel_ratio = 0.5;
      };

      "$mod" = "SUPER";

      exec-once = [
        "hyprpanel"
        "wl-paste --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      # Keybinds (Omarchy-inspired)
      bind = [
        # Core
        "$mod, RETURN, exec, ghostty"
        "$mod, SPACE, exec, walker"
        "$mod, Q, killactive,"

        # Window management
        "$mod, F, fullscreen, 0"
        "$mod, T, togglefloating,"
        "$mod, P, pin,"
        "$mod, M, fullscreen, 1" # maximize (keeps gaps)

        # Focus (vim-style)
        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"

        # Move windows (vim-style)
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, L, movewindow, r"

        # Resize mode
        "$mod CTRL, H, resizeactive, -50 0"
        "$mod CTRL, J, resizeactive, 0 50"
        "$mod CTRL, K, resizeactive, 0 -50"
        "$mod CTRL, L, resizeactive, 50 0"

        # Workspaces 1-10
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Special workspace (scratchpad)
        "$mod, grave, togglespecialworkspace, magic"
        "$mod SHIFT, grave, movetoworkspace, special:magic"

        # Window switcher
        "$mod, TAB, exec, walker -m windows"

        # Screenshots (grimblast)
        ", Print, exec, grimblast copy area"
        "$mod, Print, exec, grimblast copy output"
        "$mod SHIFT, Print, exec, grimblast copy screen"

        # Clipboard picker
        "$mod, V, exec, ~/.local/bin/walker-clipboard"

        # Lock screen
        "$mod CTRL, L, exec, hyprlock"

        # Color picker
        "$mod SHIFT, C, exec, hyprpicker -a"

        # OSK
        "$mod, O, exec, ~/.local/bin/osk-toggle"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow" # Super + left click to drag
        "$mod, mouse:273, resizewindow" # Super + right click to resize
      ];

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 1;
        "col.active_border" = "rgba(89b4facc)";
        "col.inactive_border" = "rgba(31324466)";
      };

      decoration = {
        rounding = 8;
        active_opacity = 1.0;
        inactive_opacity = 0.95;

        blur = {
          enabled = true;
          size = 4;
          passes = 2;
          new_optimizations = true;
        };

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1e1e2e40)";
        };
      };

      animations = {
        enabled = true;
        bezier = "ease, 0.25, 0.1, 0.25, 1";

        animation = [
          "windows, 1, 3, ease, slide"
          "windowsOut, 1, 3, ease, popin 80%"
          "fade, 1, 3, ease"
          "workspaces, 1, 3, ease, slide"
        ];
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
  ## Programs (walker, hyprpanel, hyprlock)
  ########################################

  programs = {
    hyprpanel = {
      enable = true;
      systemd.enable = true;

      settings = {
        bar = {
          launcher = {
            autoDetectIcon = true;
            icon = "󱄅";
          };
          workspaces = {
            show_icons = false;
            showWsIcons = false;
            show_numbered = true;
            numbered_active_indicator = "highlight";
          };
          windowtitle = {
            label = true;
            truncation_size = 30;
          };
          network = {
            showWifiInfo = true;
            label = false;
          };
          bluetooth = {
            label = false;
          };
          volume = {
            label = false;
          };
          battery = {
            label = true;
          };
          clock = {
            format = "%H:%M";
          };
          notifications = {
            show_total = true;
          };
        };

        menus = {
          clock = {
            time = {
              military = true;
            };
            weather.enabled = false;
          };
          dashboard = {
            powermenu.avatar.image = "";
            stats.enable_gpu = false;
            shortcuts.enabled = false;
            directories.enabled = false;
          };
        };

        theme = {
          bar = {
            transparent = true;
            outer_spacing = "0.4em";
            buttons = {
              radius = "0.5em";
            };
          };
          font = {
            name = "JetBrainsMono Nerd Font";
            size = "14px";
          };
        };

        # Bar layout
        "bar.layouts" = {
          "*" = {
            left = [
              "dashboard"
              "workspaces"
              "windowtitle"
            ];
            middle = [ "media" ];
            right = [
              "volume"
              "network"
              "bluetooth"
              "battery"
              "systray"
              "clock"
              "notifications"
            ];
          };
        };
      };
    };

    walker = {
      enable = true;
      runAsService = true;

      config = {
        placeholder = "Search...";
        terminal = "ghostty";
        ignore_mouse = false;
        orientation = "vertical";
        enable_typeahead = true;
        show_initial_entries = true;
        theme = "catppuccin";

        builtins = {
          applications = {
            weight = 5;
            name = "applications";
            placeholder = "Applications";
            prioritize_new = true;
            actions = true;
          };

          clipboard = {
            switcher_only = true;
            name = "clipboard";
            placeholder = "Clipboard";
            weight = 5;
            max_entries = 10;
          };

          calc = {
            weight = 5;
            name = "calc";
            placeholder = "Calculator";
            min_chars = 0;
          };

          websearch = {
            weight = 1;
            name = "websearch";
            placeholder = "Search the web";
            engines = [ "duckduckgo" ];
          };

          hyprland = {
            weight = 3;
            name = "windows";
            placeholder = "Windows";
            context_aware = true;
          };

          symbols = {
            weight = 3;
            name = "symbols";
            placeholder = "Symbols";
          };

          runner = {
            weight = 1;
            name = "runner";
            placeholder = "Run command";
          };

          finder = {
            weight = 3;
            name = "finder";
            placeholder = "Files";
            switcher_only = true;
          };
        };
      };

      # Custom Catppuccin theme
      themes = {
        catppuccin = {
          style = ''
            @define-color background rgba(17, 17, 27, 0.94);
            @define-color foreground #cdd6f4;
            @define-color surface0 #313244;
            @define-color blue #89b4fa;
            @define-color lavender #b4befe;
            @define-color subtext0 #a6adc8;

            #window { background: transparent; }

            #box {
              background: @background;
              border-radius: 18px;
              padding: 12px;
            }

            #search {
              background: @surface0;
              border-radius: 12px;
              padding: 10px 14px;
              color: @foreground;
              font-size: 16px;
            }

            #search:focus { border: 1px solid @blue; }

            #list { margin-top: 8px; }

            #list row {
              padding: 8px 10px;
              border-radius: 10px;
              margin: 2px 0;
            }

            #list row:selected { background: alpha(@blue, 0.22); }
            #list row label { color: @foreground; }
            #list row:selected label { color: @lavender; }
            .activationlabel { color: @subtext0; font-size: 12px; }
          '';
        };
      };
    };

    hyprlock.enable = true;
  };
}
