{
  config,
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
      nautilus # file manager

      # Media control (Omarchy)
      playerctl
      brightnessctl

      # Notifications (Omarchy uses mako)
      mako

      # Dev tools (Omarchy)
      lazydocker

      # Wallpaper (Variety + swaybg backend)
      variety
      swaybg

      # App launcher
      rofi-wayland
      rofi-power-menu
      rofimoji # emoji picker
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

      ".local/bin/rofi-clipboard" = {
        text = ''
          #!/usr/bin/env bash
          cliphist list \
            | rofi -dmenu -p "Clipboard" \
            | cliphist decode \
            | wl-copy
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
        "hyprpanel"
        "mako" # notifications daemon
        "variety" # wallpaper manager (auto-restores last wallpaper)
        "wl-paste --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      # Keybinds (Omarchy - from official manual)
      bind = [
        # Launching apps (Super + Shift + key)
        "$mod, RETURN, exec, ghostty"
        "$mod, SPACE, exec, rofi -show drun"
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
        "$mod CTRL, V, exec, ~/.local/bin/rofi-clipboard" # clipboard manager

        # Toggles
        "$mod CTRL, I, exec, hyprlock" # toggle idle/lock
        "$mod CTRL, N, exec, hyprsunset" # toggle nightlight
        "$mod SHIFT, SPACE, exec, pkill -SIGUSR1 hyprpanel" # toggle top bar
        "$mod, BACKSPACE, exec, hyprctl dispatch setprop active opaque toggle"

        # Notifications (Omarchy uses comma)
        "$mod, COMMA, exec, makoctl dismiss"
        "$mod SHIFT, COMMA, exec, makoctl dismiss --all"
        "$mod CTRL, COMMA, exec, makoctl mode -t do-not-disturb"
        "$mod ALT, COMMA, exec, makoctl invoke"

        # Emoji picker
        "$mod CTRL, E, exec, rofimoji"

        # System
        "$mod, ESCAPE, exec, rofi -show power-menu -modi power-menu:rofi-power-menu" # lock/suspend/restart/shutdown

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
  ## Programs (rofi, hyprpanel, hyprlock)
  ########################################

  programs = {
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      terminal = "${pkgs.ghostty}/bin/ghostty";
      # theme handled by catppuccin module
      extraConfig = {
        modi = "drun,run,window";
        show-icons = true;
        drun-display-format = "{name}";
        disable-history = false;
        sorting-method = "fzf";
      };
    };

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

    hyprlock.enable = true;
  };
}
