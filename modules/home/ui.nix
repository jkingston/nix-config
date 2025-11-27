{
  pkgs,
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

      # Utilities
      bluez # for bluetooth
      grimblast # for screenshots
      hyprpicker # for color picker
      hyprsunset # for blue light filter
      btop # system monitor

      # Browser / misc
      chromium
      nautilus # file manager

      # Media control (Omarchy)
      playerctl
      brightnessctl

      # Dev tools (Omarchy)
      lazydocker

      # Wallpaper (Variety + swaybg backend)
      variety
      swaybg

      # App launcher
      walker
      libqalculate # calculator backend for walker
      wlogout # power menu
    ];

    file = {
      # Variety wallpaper setter script for swaybg
      ".config/variety/scripts/set_wallpaper" = {
        text = ''
          #!/usr/bin/env bash
          # Kill any existing swaybg instance
          pkill swaybg 2>/dev/null
          # Set new wallpaper
          swaybg -i "$1" -m fill &
        '';
        executable = true;
      };

      ".local/bin/osk-toggle" = {
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
        "variety" # wallpaper manager (auto-restores last wallpaper)
        "wl-paste --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        # Note: waybar and mako are started via systemd services
      ];

      # Keybinds (Omarchy - from official manual)
      bind = [
        # Launching apps (Super + Shift + key)
        "$mod, RETURN, exec, ghostty"
        "$mod, SPACE, exec, walker"
        "$mod SHIFT, B, exec, chromium"
        "$mod SHIFT, N, exec, ghostty -e nvim"
        "$mod SHIFT, T, exec, ghostty -e btop"
        "$mod SHIFT, F, exec, nautilus" # file manager
        "$mod SHIFT, D, exec, ghostty -e lazydocker"
        "$mod CTRL, S, exec, localsend" # share menu

        # Window management
        "$mod, W, killactive,"
        "CTRL ALT, DELETE, exec, hyprctl dispatch closewindow address:*" # close all
        "$mod, T, togglefloating," # toggle tiling/floating
        "$mod, O, pin," # sticky'n'floating (pin)
        "$mod, F, fullscreen, 0"
        "$mod ALT, F, fullscreen, 1" # full width (maximize)
        "$mod, G, togglegroup," # window grouping
        "$mod ALT, G, moveoutofgroup," # move out of group
        "$mod ALT, TAB, changegroupactive," # cycle group windows

        # Focus (arrow keys - Omarchy)
        "$mod, LEFT, movefocus, l"
        "$mod, RIGHT, movefocus, r"
        "$mod, UP, movefocus, u"
        "$mod, DOWN, movefocus, d"

        # Swap windows (Omarchy)
        "$mod SHIFT, LEFT, swapwindow, l"
        "$mod SHIFT, RIGHT, swapwindow, r"
        "$mod SHIFT, UP, swapwindow, u"
        "$mod SHIFT, DOWN, swapwindow, d"

        # Resize (Omarchy: Equal=grow left, Minus=grow right)
        "$mod, EQUAL, resizeactive, -100 0"
        "$mod, MINUS, resizeactive, 100 0"
        "$mod SHIFT, EQUAL, resizeactive, 0 100"
        "$mod SHIFT, MINUS, resizeactive, 0 -100"

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

        # Workspace navigation (Omarchy)
        "$mod, TAB, workspace, e+1"
        "$mod SHIFT, TAB, workspace, e-1"
        "$mod CTRL, TAB, workspace, previous"

        # Scratchpad (Omarchy uses S, not grave)
        "$mod, S, togglespecialworkspace, magic"
        "$mod ALT, S, movetoworkspace, special:magic"

        # Screenshots (Omarchy)
        ", Print, exec, grimblast edit area" # screenshot with editing
        "SHIFT, Print, exec, grimblast copy screen" # screenshot to clipboard
        "$mod, Print, exec, hyprpicker -a" # color picker

        # Clipboard (Omarchy universal)
        "$mod, C, exec, wl-copy"
        "$mod, V, exec, wl-paste"
        "$mod CTRL, V, exec, walker -m clipboard" # clipboard manager

        # Toggles
        "$mod CTRL, I, exec, hyprlock" # toggle idle/lock
        "$mod ALT, N, exec, hyprsunset" # toggle nightlight
        "$mod SHIFT, SPACE, exec, pkill -SIGUSR1 waybar" # toggle top bar
        "$mod, BACKSPACE, exec, hyprctl dispatch setprop active opaque toggle"

        # Notifications (Mako)
        "$mod CTRL, N, exec, makoctl dismiss" # dismiss notification
        "$mod CTRL SHIFT, N, exec, makoctl dismiss -a" # dismiss all notifications

        # Emoji picker
        "$mod CTRL, E, exec, walker -m emojis"

        # System
        "$mod, ESCAPE, exec, wlogout" # lock/suspend/restart/shutdown

        # Mouse scroll for workspaces (Omarchy)
        "$mod, MOUSE_DOWN, workspace, e+1"
        "$mod, MOUSE_UP, workspace, e-1"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow" # Super + left click to drag
        "$mod, mouse:273, resizewindow" # Super + right click to resize
      ];

      # Media keys (Omarchy-style)
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
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
  ## Config files (Ghostty, Walker)
  ########################################

  xdg.configFile = {
    "ghostty/config".text = ''
      font-family = CaskaydiaCove Nerd Font
      font-size = 11
      theme = catppuccin-mocha

      window-decoration = none
      window-padding-x = 8
      window-padding-y = 8
    '';

    "walker/config.toml".text = ''
      placeholder = "Search..."
      fullscreen = false
      ssh_host_file = ""
      terminal = "ghostty"

      [search]
      delay = 0
      hide_icons = false

      [activation_mode]
      disabled = true

      [builtins.applications]
      weight = 5
      name = "applications"
      placeholder = "Applications"

      [builtins.runner]
      weight = 4
      name = "runner"

      [builtins.websearch]
      weight = 1
      name = "websearch"

      [builtins.calc]
      weight = 3

      [builtins.clipboard]
      weight = 4
      max_entries = 50

      [builtins.emojis]
      weight = 2
    '';

    "walker/style.css".text = ''
      /* Catppuccin Mocha */
      @define-color base #1e1e2e;
      @define-color surface0 #313244;
      @define-color surface1 #45475a;
      @define-color text #cdd6f4;
      @define-color subtext0 #a6adc8;
      @define-color blue #89b4fa;

      window {
        background-color: alpha(@base, 0.95);
        border-radius: 12px;
        border: 1px solid @surface0;
      }

      #box {
        margin: 10px;
      }

      #search {
        background-color: @surface0;
        color: @text;
        border-radius: 8px;
        padding: 10px 14px;
        font-size: 14px;
      }

      #list {
        background: transparent;
        margin-top: 10px;
      }

      row {
        padding: 8px 12px;
        border-radius: 6px;
      }

      row:selected {
        background-color: @surface1;
      }

      row label {
        color: @text;
      }

      row:selected label {
        color: @blue;
      }
    '';
  };

  ########################################
  ## Programs (waybar, hyprlock)
  ########################################

  programs = {
    waybar = {
      enable = true;
      systemd.enable = true;

      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 28;
        spacing = 4;

        modules-left = [
          "custom/launcher"
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "tray"
          "bluetooth"
          "network"
          "pulseaudio"
          "cpu"
          "battery"
        ];

        "custom/launcher" = {
          format = "󱄅";
          on-click = "walker";
          tooltip = false;
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            active = "●";
            default = "○";
            empty = "○";
          };
          on-click = "activate";
          sort-by-number = true;
        };

        "hyprland/window" = {
          max-length = 40;
          separate-outputs = true;
        };

        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%A %d %B %Y}";
          tooltip-format = "<tt>{calendar}</tt>";
        };

        battery = {
          format = "{icon} {capacity}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          states = {
            warning = 20;
            critical = 10;
          };
        };

        network = {
          format-wifi = " {signalStrength}%";
          format-ethernet = "";
          format-disconnected = "󰤭";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          on-click = "nm-connection-editor";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "";
          format-icons.default = [
            ""
            ""
            ""
          ];
          on-click = "pavucontrol";
        };

        cpu = {
          format = " {usage}%";
          interval = 3;
          on-click = "ghostty -e btop";
        };

        bluetooth = {
          format = "";
          format-connected = " {num_connections}";
          on-click = "blueman-manager";
        };

        tray = {
          icon-size = 14;
          spacing = 8;
        };
      };

      style = ''
        * {
          font-family: "CaskaydiaCove Nerd Font";
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background-color: alpha(@base, 0.9);
          color: @text;
          border-bottom: 1px solid @surface0;
        }

        .modules-left { margin-left: 8px; }
        .modules-right { margin-right: 8px; }

        #workspaces button {
          padding: 0 6px;
          margin: 2px;
          color: @overlay0;
          background: transparent;
          border-radius: 4px;
        }

        #workspaces button.active {
          color: @blue;
          background: @surface0;
        }

        #clock, #battery, #cpu, #network, #pulseaudio, #bluetooth, #tray {
          padding: 0 10px;
          margin: 4px 2px;
        }

        #battery.warning { color: @yellow; }
        #battery.critical { color: @red; }

        #custom-launcher {
          font-size: 16px;
          padding: 0 12px;
          color: @blue;
        }
      '';
    };

    hyprlock.enable = true;
  };

  ########################################
  ## Mako notifications
  ########################################

  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      width = 350;
      height = 100;
      margin = "10";
      padding = "15";
      border-size = 2;
      border-radius = 8;
      default-timeout = 5000;
      max-visible = 5;
      layer = "overlay";
      icons = true;
      max-icon-size = 48;
      font = "CaskaydiaCove Nerd Font 11";
    };
  };
}
