{
  config,
  pkgs,
  lib,
  hostCfg,
  gazelle,
  ...
}:

{
  imports = [ ];

  ########################################
  ## XDG Portal (for dark mode detection)
  ########################################

  xdg.portal = {
    enable = lib.mkForce true; # Override Hyprland module's default
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.common = {
      default = [
        "hyprland"
        "gtk"
      ];
      # GTK portal provides dark mode setting to browsers
      "org.freedesktop.impl.portal.Settings" = "gtk";
    };
  };

  home = {
    packages =
      with pkgs;
      [
        # Core UI tools
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
        sunwait # for sunrise/sunset calculation
        btop # system monitor
        swayosd # OSD for volume/brightness

        # TUI managers (Omarchy style)
        # nmtui for WiFi (comes with networkmanager)
        bluetui # Bluetooth TUI

        # Misc
        nautilus # file manager

        # Media control (Omarchy)
        playerctl
        brightnessctl

        # Dev tools (Omarchy)
        lazydocker

        # Wallpaper
        swww # wallpaper daemon (CLI-based, no config file needed)
        waypaper # GUI wallpaper picker with gallery view

        # App launcher
        walker
        libqalculate # calculator backend for walker
        wlogout # power menu
      ]
      ++ [
        gazelle.packages.${pkgs.system}.default # WiFi TUI
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

      # Random wallpaper script (used by Super+Alt+W and timer)
      ".local/bin/wallpaper-random" = {
        text = ''
          #!/usr/bin/env bash
          WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

          # Pick random image from all subdirs (-L follows symlinks)
          selected=$(find -L "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | shuf -n1)

          if [ -n "$selected" ]; then
            # Trendy cursor-position grow transition with bouncy bezier
            swww img "$selected" \
              --transition-type grow \
              --transition-pos "$(hyprctl cursorpos)" \
              --transition-duration 0.7 \
              --transition-fps 60 \
              --transition-bezier .43,1.19,1,.4
          fi
        '';
        executable = true;
      };

      # Keybind help overlay (Omarchy-style using Walker)
      ".local/bin/keybind-help" = {
        text = ''
          #!/usr/bin/env bash
          # Display keybindings in Walker dmenu
          hyprctl -j binds | jq -r '.[] | "\(.modmask)|\(.key)|\(.dispatcher)|\(.arg)"' | \
            awk -F'|' '{
              mod=""
              if ($1 == 0) mod=""
              else if ($1 == 1) mod="SHIFT"
              else if ($1 == 4) mod="CTRL"
              else if ($1 == 8) mod="ALT"
              else if ($1 == 64) mod="SUPER"
              else if ($1 == 65) mod="SUPER SHIFT"
              else if ($1 == 68) mod="SUPER CTRL"
              else if ($1 == 69) mod="SUPER SHIFT CTRL"
              else if ($1 == 72) mod="SUPER ALT"
              else if ($1 == 73) mod="SUPER SHIFT ALT"
              else mod="MOD " $1

              key = $2
              gsub(/^[ \t]+|[ \t]+$/, "", key)

              action = $3 " " $4
              gsub(/^[ \t]+|[ \t]+$/, "", action)

              if (key != "" && action != " ") {
                if (mod != "") printf "%-25s → %s\n", mod " + " key, action
                else printf "%-25s → %s\n", key, action
              }
            }' | sort -u | walker --dmenu -p 'Keybindings'
        '';
        executable = true;
      };

      # Hyprsunset gradual transition (30 min fade)
      ".local/bin/hyprsunset-transition" = {
        text = ''
          #!/usr/bin/env bash
          # Gradual transition between day/night over 30 minutes
          # Usage: hyprsunset-transition day|night

          MODE="$1"
          STEPS=30
          STEP_DURATION=60  # 60 seconds per step

          DAY_TEMP=6500
          NIGHT_TEMP=4500

          if [ "$MODE" = "day" ]; then
            START=$NIGHT_TEMP
            END=$DAY_TEMP
            rm -f /tmp/hyprsunset-night
          else
            START=$DAY_TEMP
            END=$NIGHT_TEMP
            touch /tmp/hyprsunset-night
          fi

          pkill -SIGRTMIN+10 waybar || true

          for i in $(seq 0 $STEPS); do
            TEMP=$((START + (END - START) * i / STEPS))
            hyprctl hyprsunset temperature $TEMP
            [ $i -lt $STEPS ] && sleep $STEP_DURATION
          done

          # Final state - identity for day mode
          if [ "$MODE" = "day" ]; then
            hyprctl hyprsunset identity
          fi
        '';
        executable = true;
      };

      # Hyprsunset waybar toggle (manual override)
      ".local/bin/hyprsunset-toggle" = {
        text = ''
          #!/usr/bin/env bash
          # Toggle night light on/off (manual override)
          # Uses hyprctl IPC to control running hyprsunset

          STATE_FILE="/tmp/hyprsunset-night"

          if [ -f "$STATE_FILE" ]; then
            hyprctl hyprsunset identity
            rm "$STATE_FILE"
            notify-send -t 1500 "󰹏 Night Light Off"
            echo "󰹏"
          else
            hyprctl hyprsunset temperature 4500
            touch "$STATE_FILE"
            notify-send -t 1500 "󱩌 Night Light On"
            echo "󱩌"
          fi
          pkill -SIGRTMIN+10 waybar
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

    settings = {
      # Monitor scaling from hostCfg
      monitor = "${hostCfg.internalMonitor}, preferred, auto, ${builtins.toString hostCfg.scale}";

      input = {
        kb_layout = "gb";

        touchpad = {
          natural_scroll = true;
          clickfinger_behavior = true;
          tap-to-click = true;
        };
      };

      # Touchpad gestures (Hyprland 0.51+ syntax)
      gestures = {
        workspace_swipe_forever = true;
      };

      gesture = "3, horizontal, workspace";

      "$mod" = "SUPER";

      exec-once = [
        "swayosd-server" # OSD for volume/brightness
        "wl-paste --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "hypridle" # idle lock daemon (backup in case systemd service fails)
        "hyprsunset" # blue light filter (controlled via IPC by systemd timers)
        # Note: waybar and mako are started via systemd services
        "swww-daemon && ~/.local/bin/wallpaper-random" # Start wallpaper daemon and set initial wallpaper
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

        # Focus (arrow keys)
        "$mod, LEFT, movefocus, l"
        "$mod, RIGHT, movefocus, r"
        "$mod, UP, movefocus, u"
        "$mod, DOWN, movefocus, d"

        # Focus (vim keys)
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # Swap windows (arrow keys)
        "$mod SHIFT, LEFT, swapwindow, l"
        "$mod SHIFT, RIGHT, swapwindow, r"
        "$mod SHIFT, UP, swapwindow, u"
        "$mod SHIFT, DOWN, swapwindow, d"

        # Swap windows (vim keys)
        "$mod SHIFT, H, swapwindow, l"
        "$mod SHIFT, L, swapwindow, r"
        "$mod SHIFT, K, swapwindow, u"
        "$mod SHIFT, J, swapwindow, d"

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
        "$mod SHIFT, SPACE, exec, pkill -SIGUSR1 waybar" # toggle top bar
        "$mod SHIFT, O, exec, hyprctl --batch 'dispatch setprop active opaque toggle; dispatch setprop active noblur toggle'" # toggle transparency (Omarchy)

        # Notifications (Mako)
        "$mod CTRL, N, exec, makoctl dismiss" # dismiss notification
        "$mod CTRL SHIFT, N, exec, makoctl dismiss -a" # dismiss all notifications

        # Emoji picker
        "$mod CTRL, E, exec, walker -m emojis"

        # Wallpaper controls (swww + waypaper)
        "$mod CTRL, W, exec, waypaper"
        "$mod ALT, W, exec, ~/.local/bin/wallpaper-random"

        # Keybind help (Omarchy-style)
        "$mod, slash, exec, ~/.local/bin/keybind-help"

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

      # Media keys with SwayOSD visual feedback
      bindel = [
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
        ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
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

      # Focus browser when clicking URLs from another workspace
      misc = {
        focus_on_activate = true;
      };

      # Omarchy styling
      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 2;
        # Colors set by catppuccin module
      };

      decoration = {
        rounding = 0; # Square windows (Omarchy style)
        active_opacity = 0.95;
        inactive_opacity = 0.88;
        fullscreen_opacity = 1.0;

        blur = {
          enabled = true;
          size = 6;
          passes = 4;
          ignore_opacity = true; # Critical for blur on transparent windows
          xray = false;
          special = true;
          new_optimizations = true;
          noise = 0.02;
          contrast = 0.9;
          brightness = 0.8;
          popups = true;
          popups_ignorealpha = 0.6;
        };

        shadow = {
          enabled = true;
          range = 8;
          render_power = 3;
          color = "rgba(0, 0, 0, 0.5)";
        };
      };

      animations = {
        enabled = true;

        # Smooth bezier curves (no bounce/overshoot)
        bezier = [
          "smooth, 0.25, 0.1, 0.25, 1.0"
          "smoothOut, 0.0, 0.0, 0.2, 1.0"
          "smoothIn, 0.4, 0.0, 1.0, 1.0"
          "liner, 1, 1, 1, 1"
        ];

        animation = [
          "windows, 1, 6, smooth, slide"
          "windowsIn, 1, 6, smoothOut, slide"
          "windowsOut, 1, 5, smoothIn, slide"
          "windowsMove, 1, 5, smooth, slide"
          "border, 1, 1, liner"
          "fade, 1, 10, default"
          "workspaces, 1, 5, smooth"
        ];
      };

      # Floating TUI overlay windows (Omarchy style)
      # Note: Ghostty requires reverse-domain format for --class (GTK requirement)
      windowrulev2 = [
        "float, class:^(com\\.floating\\.tui)$"
        "center, class:^(com\\.floating\\.tui)$"
        "size 800 600, class:^(com\\.floating\\.tui)$"
        # Also match initialClass for newly spawned windows
        "float, initialClass:^(com\\.floating\\.tui)$"
        "center, initialClass:^(com\\.floating\\.tui)$"
        "size 800 600, initialClass:^(com\\.floating\\.tui)$"
        # Waypaper wallpaper picker overlay
        "float, class:^(waypaper)$"
        "center, class:^(waypaper)$"
        "size 900 700, class:^(waypaper)$"
        # Apps that need full opacity (video, gaming, etc.)
        "opacity 1.0 override 1.0 override, class:^(mpv)$"
        "opacity 1.0 override 1.0 override, class:^(vlc)$"
        "opacity 1.0 override 1.0 override, class:^(com.obsproject.Studio)$"
        "opacity 1.0 override 1.0 override, class:^(zoom)$"
        "opacity 1.0 override 1.0 override, class:^(steam_app_.*)$"
        "opacity 1.0 override 1.0 override, fullscreen:1"
        # Slightly more transparent for terminals
        "opacity 0.92 0.85, class:^(ghostty)$"
        # File manager
        "opacity 0.95 0.9, class:^(org.gnome.Nautilus)$"
      ];

      # Layer rules for blur on overlays
      layerrule = [
        "blur, walker"
        "blur, waybar"
        "blur, wlogout"
        "ignorezero, walker"
        "ignorezero, waybar"
      ];
    };
  };

  ########################################
  ## Config files
  ########################################

  xdg.configFile = {
    # Waypaper - GUI wallpaper picker with swww backend
    "waypaper/config.ini".text = ''
      [Settings]
      folder = ~/Pictures/Wallpapers
      backend = swww
      monitors = All
      fill = Fill
      sort = name
      color = #1e1e2e
      subfolders = True
      swww_transition_type = grow
      swww_transition_step = 90
      swww_transition_duration = 0.7
      swww_transition_fps = 60
      swww_transition_angle = 0
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
    # Chromium with Wayland touchpad gestures
    chromium = {
      enable = true;
      commandLineArgs = [
        "--enable-features=TouchpadOverscrollHistoryNavigation"
      ];
    };

    # Gazelle - modern NetworkManager TUI (replaces nmtui)
    gazelle.enable = true;

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
          "custom/nightlight"
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
          on-click = "ghostty --class=com.floating.tui -e gazelle";
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
          on-click = "ghostty --class=com.floating.tui -e bluetui";
        };

        tray = {
          icon-size = 16;
          spacing = 8;
          show-passive-items = true;
        };

        "power-profiles-daemon" = {
          format = "{icon}";
          tooltip-format = "Profile: {profile}";
          format-icons = {
            default = "󰗑";
            performance = "󰓅";
            balanced = "󰾅";
            power-saver = "󰾆";
          };
        };

        "custom/nightlight" = {
          format = "{}";
          exec = "[ -f /tmp/hyprsunset-night ] && echo '󱩌' || echo '󰹏'";
          interval = "once";
          signal = 10;
          on-click = "~/.local/bin/hyprsunset-toggle";
          tooltip = false;
        };
      };

      # Omarchy Catppuccin style with blur support
      style = ''
        @define-color foreground #cdd6f4;
        @define-color background #181824;

        * {
          background-color: transparent; /* Transparent for Hyprland blur */
          color: @foreground;
          border: none;
          border-radius: 0;
          min-height: 0;
          font-family: 'JetBrainsMono Nerd Font';
          font-size: 12px;
        }

        window#waybar {
          background-color: alpha(@background, 0.7); /* Semi-transparent for blur */
        }

        .modules-left {
          margin-left: 8px;
        }

        .modules-right {
          margin-right: 8px;
        }

        #workspaces button {
          all: initial;
          font-family: 'JetBrainsMono Nerd Font';
          background-color: transparent;
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
        #custom-launcher,
        #network,
        #bluetooth {
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
          background-color: alpha(@background, 0.85);
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

  services.hypridle = lib.mkIf (!hostCfg.isVM) {
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

  ########################################
  ## Wallpaper rotation timer (swww)
  ########################################

  systemd.user.services.wallpaper-rotate = {
    Unit.Description = "Rotate wallpaper randomly";
    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/.local/bin/wallpaper-random";
    };
  };

  systemd.user.timers.wallpaper-rotate = {
    Unit.Description = "Rotate wallpaper every hour";
    Timer = {
      OnCalendar = "hourly";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  ########################################
  ## Hyprsunset sunrise/sunset scheduling
  ########################################

  # Sunrise transition - gradual fade to day mode
  systemd.user.services.hyprsunset-day = {
    Unit.Description = "Gradual transition to day mode at sunrise";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "hyprsunset-day" ''
        # Wait for sunrise (London coordinates)
        ${pkgs.sunwait}/bin/sunwait sun up 51.5074N 0.1278W
        # Gradual 30-minute transition to day mode
        ${config.home.homeDirectory}/.local/bin/hyprsunset-transition day
      ''}";
    };
  };

  systemd.user.timers.hyprsunset-day = {
    Unit.Description = "Trigger sunrise transition";
    Timer = {
      OnCalendar = "*-*-* 04:00:00"; # Run at 4am daily
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # Sunset transition - gradual fade to night mode
  systemd.user.services.hyprsunset-night = {
    Unit.Description = "Gradual transition to night mode at sunset";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "hyprsunset-night" ''
        # Wait for sunset (London coordinates)
        ${pkgs.sunwait}/bin/sunwait sun down 51.5074N 0.1278W
        # Gradual 30-minute transition to night mode
        ${config.home.homeDirectory}/.local/bin/hyprsunset-transition night
      ''}";
    };
  };

  systemd.user.timers.hyprsunset-night = {
    Unit.Description = "Trigger sunset transition";
    Timer = {
      OnCalendar = "*-*-* 14:00:00"; # Run at 2pm daily
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  ########################################
  ## Ghostty terminal
  ########################################

  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 10;
      window-decoration = false;
      window-padding-x = 8;
      window-padding-y = 8;
    };
  };
}
