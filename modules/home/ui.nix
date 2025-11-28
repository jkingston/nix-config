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

      # Wallpaper
      swww # wallpaper daemon
      variety # wallpaper auto-rotator

      # App launcher
      walker
      libqalculate # calculator backend for walker
      wlogout # power menu
    ];

    file = {
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

      # Variety swww backend script
      ".config/variety/scripts/set_wallpaper" = {
        text = ''
          #!/usr/bin/env bash
          swww img "$1" --transition-type fade --transition-duration 1
        '';
        executable = true;
      };

      # Catppuccin wallpaper collections (~386 wallpapers)
      "Pictures/Wallpapers/catppuccin-mocha".source = pkgs.fetchFromGitHub {
        owner = "orangci";
        repo = "walls-catppuccin-mocha";
        rev = "master";
        sha256 = "0bzs76iqhxa53azlayb8rwmaxakwv0fz08lh9dfykh2w4hfikqrp";
      };

      "Pictures/Wallpapers/catppuccin-official".source = pkgs.fetchFromGitHub {
        owner = "zhichaoh";
        repo = "catppuccin-wallpapers";
        rev = "main";
        sha256 = "0rd6hfd88bsprjg68saxxlgf2c2lv1ldyr6a8i7m4lgg6nahbrw7";
      };
    };
  };

  ########################################
  ## Hyprland (shared settings)
  ########################################

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    systemd.variables = [ "--all" ]; # Export PATH to systemd for hypridle
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
        "swww-daemon" # wallpaper daemon
        "variety" # wallpaper auto-rotator
        "wl-paste --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "hypridle" # idle lock daemon (backup in case systemd service fails)
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

        # Wallpaper picker (Omarchy)
        "$mod CTRL, W, exec, variety --preferences"

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
        # Lid switch - lock on close, wake display on open
        ", switch:on:Lid Switch, exec, pidof hyprlock || hyprlock"
        ", switch:off:Lid Switch, exec, hyprctl dispatch dpms on"
      ];

      # Omarchy styling
      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 2;
        # Colors set by catppuccin module
      };

      decoration = {
        rounding = 0; # Square windows (Omarchy style)
        active_opacity = 1.0;
        inactive_opacity = 0.95;

        blur = {
          enabled = true;
          size = 2;
          passes = 2;
          brightness = 0.6;
          contrast = 0.75;
        };

        shadow = {
          enabled = true;
          range = 2;
          render_power = 3;
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
      font-family = JetBrainsMono Nerd Font
      font-size = 10
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
        height = 26;
        spacing = 0;

        modules-left = [
          "custom/launcher"
          "hyprland/workspaces"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "tray"
          "bluetooth"
          "network"
          "pulseaudio"
          "cpu"
          "power-profiles-daemon"
          "battery"
        ];

        "custom/launcher" = {
          format = "󱄅";
          on-click = "walker";
          tooltip = false;
        };

        "hyprland/workspaces" = {
          on-click = "activate";
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "0";
            active = "󱓻";
            default = "";
          };
          persistent-workspaces = {
            "*" = 5;
          };
        };

        clock = {
          format = "{:%A %H:%M}";
          format-alt = "{:%d %B %Y}";
          tooltip = false;
        };

        network = {
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format = "{icon}";
          format-wifi = "{icon}";
          format-ethernet = "󰀂";
          format-disconnected = "󰤮";
          tooltip-format-wifi = "{essid} ({signalStrength}%)\n⇣{bandwidthDownBytes} ⇡{bandwidthUpBytes}";
          tooltip-format-disconnected = "Disconnected";
          interval = 3;
          on-click = "nm-connection-editor";
        };

        battery = {
          format = "{capacity}% {icon}";
          format-discharging = "{icon}";
          format-charging = "{icon}";
          format-plugged = "";
          format-icons = {
            charging = [
              "󰢜"
              "󰂆"
              "󰂇"
              "󰂈"
              "󰢝"
              "󰂉"
              "󰢞"
              "󰂊"
              "󰂋"
              "󰂅"
            ];
            default = [
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
          };
          format-full = "󰂅";
          tooltip-format-discharging = "{power:.1f}W ↓ {capacity}%";
          tooltip-format-charging = "{power:.1f}W ↑ {capacity}%";
          interval = 5;
          on-click = "wlogout";
          states = {
            warning = 20;
            critical = 10;
          };
        };

        pulseaudio = {
          format = "{icon}";
          format-muted = "";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
          tooltip-format = "Volume: {volume}%";
          scroll-step = 5;
          on-click = "pavucontrol";
          on-click-right = "pamixer -t";
        };

        cpu = {
          interval = 5;
          format = "󰍛";
          on-click = "ghostty -e btop";
        };

        bluetooth = {
          format = "";
          format-disabled = "󰂲";
          format-connected = "󰂱";
          tooltip-format = "Devices: {num_connections}";
          on-click = "blueman-manager";
        };

        tray = {
          icon-size = 12;
          spacing = 17;
        };

        "power-profiles-daemon" = {
          format = "{icon}";
          tooltip-format = "Profile: {profile}";
          format-icons = {
            default = "";
            performance = "";
            balanced = "";
            power-saver = "";
          };
        };
      };

      # Omarchy Catppuccin style
      style = ''
        @define-color foreground #cdd6f4;
        @define-color background #181824;

        * {
          background-color: @background;
          color: @foreground;
          border: none;
          border-radius: 0;
          min-height: 0;
          font-family: 'JetBrainsMono Nerd Font';
          font-size: 12px;
        }

        .modules-left {
          margin-left: 8px;
        }

        .modules-right {
          margin-right: 8px;
        }

        #workspaces button {
          all: initial;
          padding: 0 6px;
          margin: 0 1.5px;
          min-width: 9px;
          color: @foreground;
        }

        #workspaces button.empty {
          opacity: 0.5;
        }

        #workspaces button.active {
          color: #89b4fa;
        }

        #cpu,
        #battery,
        #pulseaudio,
        #power-profiles-daemon,
        #custom-launcher {
          min-width: 12px;
          margin: 0 7.5px;
        }

        #tray {
          margin-right: 16px;
        }

        #bluetooth {
          margin-right: 17px;
        }

        #network {
          margin-right: 13px;
        }

        #clock {
          margin-left: 8.75px;
        }

        #battery.warning {
          color: #f9e2af;
        }

        #battery.critical {
          color: #f38ba8;
        }

        tooltip {
          padding: 2px;
          background-color: @background;
          color: @foreground;
        }
      '';
    };

    # Hyprlock - Omarchy style (square input, blurred background)
    hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
        };

        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
            color = "rgba(30, 30, 46, 1.0)";
          }
        ];

        input-field = [
          {
            size = "650, 100";
            position = "0, 0";
            halign = "center";
            valign = "center";
            outline_thickness = 4;
            rounding = 0; # Square corners (Omarchy style)
            outer_color = "rgba(205, 214, 244, 1.0)";
            inner_color = "rgba(30, 30, 46, 0.8)";
            font_color = "rgba(205, 214, 244, 1.0)";
            font_family = "JetBrainsMono Nerd Font";
            fade_on_empty = false;
            placeholder_text = "Enter Password";
            fail_text = "<i>$FAIL ($ATTEMPTS)</i>";
            check_color = "rgba(68, 157, 171, 1.0)";
            shadow_passes = 0;
          }
        ];
        # No labels - Omarchy keeps it minimal
      };
    };

    # Wlogout - Omarchy style (square buttons)
    wlogout = {
      enable = true;
      layout = [
        {
          label = "lock";
          action = "hyprlock";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "logout";
          action = "hyprctl dispatch exit";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "suspend";
          action = "systemctl suspend";
          text = "Suspend";
          keybind = "s";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "p";
        }
      ];
    };
  };

  ########################################
  ## Hypridle - Automatic locking
  ########################################

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        # Lock screen after 5 minutes
        {
          timeout = 300;
          on-timeout = "pidof hyprlock || hyprlock";
        }
        # Turn off display after 5.5 minutes
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        # Suspend after 30 minutes
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  ########################################
  ## Mako notifications
  ########################################

  services.mako = {
    enable = true;
    settings = {
      # Omarchy style (square corners, wider)
      anchor = "top-right";
      width = 420;
      padding = "10,15";
      margin = "20";
      border-size = 2;
      border-radius = 0; # Square corners
      default-timeout = 5000;
      max-visible = 5;
      layer = "overlay";
      icons = true;
      max-icon-size = 32;
      font = "sans-serif 14";
    };
  };
}
