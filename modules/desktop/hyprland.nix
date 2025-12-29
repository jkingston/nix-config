# Hyprland window manager configuration
{
  hostCfg,
  ...
}:

{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    systemd.variables = [ "--all" ]; # Export PATH to systemd for hypridle
    package = null;
    portalPackage = null;

    settings = {
      # Monitor scaling from hostCfg
      monitor = "${hostCfg.internalMonitor}, preferred, auto, ${builtins.toString hostCfg.scale}";

      # XWayland HiDPI - prevents blurry X11 apps, use Xft.dpi instead
      xwayland = {
        force_zero_scaling = true;
      };

      # Environment variables for toolkit scaling
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "GDK_BACKEND,wayland,x11,*"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
      ];

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
        "xrdb -merge ~/.Xresources" # Load X11 DPI settings for XWayland apps
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
}
