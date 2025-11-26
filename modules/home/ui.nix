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
        };
      };

      "$mod" = "SUPER";

      exec-once = [
        "wl-paste --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      # Keybinds that do NOT depend on monitors
      bind = [
        "$mod, RETURN, exec, ghostty"
        "$mod, SPACE, exec, walker"
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
        "$mod, S, exec, ~/.local/bin/walker-clipboard"

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
  ## Programs (walker, hyprpanel, hyprlock)
  ########################################

  programs = {
    hyprpanel = {
      enable = true;
      systemd.enable = true;
      hyprland.enable = true;
      overwrite.enable = true;

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
          name = "catppuccin_mocha";
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
            left = [ "dashboard" "workspaces" "windowtitle" ];
            middle = [ "media" ];
            right = [ "volume" "network" "bluetooth" "battery" "systray" "clock" "notifications" ];
          };
        };
      };
    };

    walker = {
      enable = true;
      runAsService = true;

      config = {
        search.placeholder = "Search...";
        terminal = "ghostty";
        ignore_mouse = false;
        ssh_host_file = "";
        orientation = "vertical";
        enable_typeahead = true;
        show_initial_entries = true;
        activation_mode.disabled = true;

        builtins = {
          applications = {
            weight = 5;
            name = "applications";
            placeholder = "Applications";
            prioritize_new = true;
            show_sub_when_single = true;
            show_icon_when_single = true;
            refresh = true;
            show_generic = false;
            actions = true;
          };

          clipboard = {
            switcher_only = true;
            name = "clipboard";
            placeholder = "Clipboard";
            weight = 5;
            image_height = 300;
            max_entries = 10;
          };

          calc = {
            weight = 5;
            name = "calc";
            placeholder = "Calculator";
            min_chars = 0;
            prefix = "=";
          };

          websearch = {
            weight = 1;
            name = "websearch";
            placeholder = "Search the web";
            prefix = "?";
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
            prefix = ":";
          };

          commands = {
            weight = 3;
            name = "commands";
            placeholder = "Commands";
            prefix = "/";
            switcher_only = true;
          };

          runner = {
            weight = 1;
            name = "runner";
            placeholder = "Run command";
            prefix = "!";
          };

          finder = {
            weight = 3;
            name = "finder";
            placeholder = "Files";
            prefix = ".";
            switcher_only = true;
          };
        };
      };

      # Catppuccin Mocha theme
      theme = {
        layout = {
          ui = {
            anchors = {
              bottom = false;
              left = false;
              right = false;
              top = true;
            };
            window = {
              h_align = "center";
              v_align = "start";
              box = {
                width = 500;
                margins = {
                  top = 200;
                };
                scroll = {
                  list = {
                    max_height = 400;
                  };
                };
              };
            };
          };
        };

        style = ''
          @define-color background rgba(17, 17, 27, 0.94);
          @define-color foreground #cdd6f4;
          @define-color surface0 #313244;
          @define-color surface1 #45475a;
          @define-color blue #89b4fa;
          @define-color lavender #b4befe;
          @define-color subtext0 #a6adc8;

          #window {
            background: transparent;
          }

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

          #search:focus {
            border: 1px solid @blue;
          }

          #list {
            margin-top: 8px;
          }

          #list row {
            padding: 8px 10px;
            border-radius: 10px;
            margin: 2px 0;
          }

          #list row:selected {
            background: alpha(@blue, 0.22);
          }

          #list row label {
            color: @foreground;
          }

          #list row:selected label {
            color: @lavender;
          }

          .activationlabel {
            color: @subtext0;
            font-size: 12px;
          }
        '';
      };
    };

    hyprlock.enable = true;
  };
}
