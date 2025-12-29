# Waybar status bar configuration
_:

{
  programs.waybar = {
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
}
