# Waybar status bar configuration
{
  lib,
  pkgs,
  hostCfg,
  ...
}:

{
  # System monitor script for waybar (smart tooltip showing top processes)
  home.file.".local/bin/waybar-sysmon" = {
    text = ''
      #!/usr/bin/env bash
      # Smart sysmon: shows what's using resources, not just percentages

      # Get top CPU process (excluding this script)
      read -r TOP_CPU_PCT TOP_CPU_NAME <<< $(${pkgs.procps}/bin/ps -eo pcpu,comm --no-headers --sort=-pcpu | head -1 | ${pkgs.gawk}/bin/awk '{print int($1), $2}')

      # Get top RAM process
      read -r TOP_RAM_KB TOP_RAM_NAME <<< $(${pkgs.procps}/bin/ps -eo rss,comm --no-headers --sort=-rss | head -1 | ${pkgs.gawk}/bin/awk '{print $1, $2}')
      TOP_RAM_GB=$(echo "scale=1; $TOP_RAM_KB / 1048576" | ${pkgs.bc}/bin/bc)

      # Get overall RAM usage
      read -r TOTAL AVAIL <<< $(${pkgs.gawk}/bin/awk '/MemTotal/ {total=$2} /MemAvailable/ {avail=$2} END {print total, avail}' /proc/meminfo)
      RAM_PCT=$((100 * (TOTAL - AVAIL) / TOTAL))

      # Build smart tooltip
      if [ "$TOP_CPU_PCT" -gt 15 ]; then
        CPU_PART="$TOP_CPU_NAME ($TOP_CPU_PCT%)"
      else
        CPU_PART="CPU: $TOP_CPU_PCT%"
      fi

      # Show top RAM process if using > 1GB
      TOP_RAM_MB=$((TOP_RAM_KB / 1024))
      if [ "$TOP_RAM_MB" -gt 1024 ]; then
        RAM_PART="$TOP_RAM_NAME (''${TOP_RAM_GB}G)"
      else
        RAM_PART="RAM: $RAM_PCT%"
      fi

      printf '{"text": "󰍛", "tooltip": "%s • %s"}\n' "$CPU_PART" "$RAM_PART"
    '';
    executable = true;
  };

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
      modules-center = [ "clock" "custom/updates" ];
      modules-right = [
        "privacy"
        "tray"
        "bluetooth"
        "network"
        "pulseaudio"
        "custom/sysmon"
      ]
      ++ lib.optionals hostCfg.isLaptop [ "power-profiles-daemon" ]
      ++ [
        "idle_inhibitor"
        "custom/nightlight"
      ]
      ++ lib.optionals hostCfg.isLaptop [
        "backlight"
        "battery"
      ];

      "custom/launcher" = {
        format = "󱄅";
        on-click = "rofi -show drun";
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
        format-alt = "{:%d %B W%V %Y}";
        tooltip = false;
      };

      privacy = {
        icon-spacing = 4;
        icon-size = 18;
        transition-duration = 250;
        modules = [
          {
            type = "screenshare";
            tooltip = true;
            tooltip-icon-size = 24;
          }
          {
            type = "audio-in";
            tooltip = true;
            tooltip-icon-size = 24;
          }
        ];
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
        tooltip-format-wifi = "{essid} ({frequency}GHz {signalStrength}%)\n⇣{bandwidthDownBytes} ⇡{bandwidthUpBytes}";
        tooltip-format-ethernet = "{ifname}: {ipaddr}\n⇣{bandwidthDownBytes} ⇡{bandwidthUpBytes}";
        tooltip-format-disconnected = "Disconnected";
        interval = 3;
        on-click = "ghostty --class=com.floating.tui -e gazelle";
      };

      pulseaudio = {
        format = "{icon}";
        format-muted = "󰝟";
        format-icons = {
          default = [
            "󰕿"
            "󰖀"
            "󰕾"
          ];
        };
        tooltip-format = "Volume: {volume}%";
        scroll-step = 5;
        on-click = "ghostty --class=com.floating.tui -e pulsemixer";
        on-click-right = "wpctl set-mute @DEFAULT_SINK@ toggle";
      };

      "custom/sysmon" = {
        exec = "~/.local/bin/waybar-sysmon";
        return-type = "json";
        interval = 5;
        on-click = "ghostty -e btop";
      };

      "custom/updates" = {
        exec = "~/.local/bin/nixos-updates-check";
        signal = 12;
        on-click = "ghostty --class=com.floating.tui -e ~/.local/bin/nixos-update";
        on-click-right = "~/.local/bin/nixos-update-menu";
        interval = 300; # Poll cache every 5 min
        tooltip = true;
        return-type = "json";
      };

      bluetooth = {
        format = "󰂯";
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

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "󰅶";
          deactivated = "󰾪";
        };
        tooltip-format-activated = "Idle prevention: on";
        tooltip-format-deactivated = "Idle prevention: off";
      };

      "custom/nightlight" = {
        format = "{}";
        return-type = "json";
        exec = "~/.local/bin/hyprsunset-status";
        interval = 60;
        signal = 10;
        on-click = "~/.local/bin/hyprsunset-toggle";
        on-click-right = "~/.local/bin/hyprsunset-settings";
      };

      backlight = {
        format = "{icon}";
        format-icons = [
          "󰃞"
          "󰃟"
          "󰃠"
        ];
        tooltip-format = "Brightness: {percent}%";
        on-scroll-up = "swayosd-client --brightness raise";
        on-scroll-down = "swayosd-client --brightness lower";
      };

      battery = {
        format = "{icon}";
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
        tooltip-format = "{power:.1f}W {capacity}%";
        interval = 5;
        on-click = "rofi -show power-menu -modi power-menu:rofi-power-menu";
        states = {
          warning = 20;
          critical = 10;
        };
      };
    };

    style = ''
      @define-color foreground #cdd6f4;
      @define-color background #181824;

      * {
        background-color: transparent;
        color: @foreground;
        border: none;
        border-radius: 0;
        min-height: 0;
        font-family: 'JetBrainsMono Nerd Font';
        font-size: 12px;
      }

      window#waybar {
        background-color: alpha(@background, 0.7);
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

      #battery,
      #pulseaudio,
      #power-profiles-daemon,
      #custom-launcher,
      #custom-nightlight,
      #custom-sysmon,
      #custom-updates,
      #idle_inhibitor,
      #backlight,
      #privacy {
        min-width: 12px;
        margin: 0 7.5px;
      }

      #custom-updates.has-updates {
        color: #f9e2af;
      }

      #custom-updates.checking {
        opacity: 0.5;
      }

      #custom-updates.dirty {
        color: #fab387;
      }

      #custom-updates.disabled {
        opacity: 0.5;
      }

      #custom-updates.error {
        color: #f38ba8;
      }

      #tray {
        margin-right: 16px;
      }

      #bluetooth {
        min-width: 12px;
        margin-right: 17px;
      }

      #network {
        min-width: 12px;
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

      #idle_inhibitor.activated {
        color: #f9e2af;
      }

      tooltip {
        padding: 2px;
        background-color: alpha(@background, 0.85);
        color: @foreground;
      }
    '';
  };
}
