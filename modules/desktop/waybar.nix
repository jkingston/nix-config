# Waybar status bar configuration
{
  lib,
  pkgs,
  hostCfg,
  ...
}:

{
  # System monitor script for waybar (CPU + RAM in tooltip)
  home.file.".local/bin/waybar-sysmon" = {
    text = ''
      #!/usr/bin/env bash
      # Output JSON for waybar with CPU and RAM stats

      # Get CPU usage (average across all cores)
      CPU=$(${pkgs.coreutils}/bin/cat /proc/stat | ${pkgs.gawk}/bin/awk '/^cpu / {
        idle=$5; total=$2+$3+$4+$5+$6+$7+$8
        if (NR>1) {
          d_idle=idle-prev_idle; d_total=total-prev_total
          printf "%.0f", 100*(1-(d_idle/d_total))
        }
        prev_idle=idle; prev_total=total
      }')

      # If first run, get a quick sample
      if [ -z "$CPU" ]; then
        read -r cpu user nice system idle iowait irq softirq < /proc/stat
        total1=$((user + nice + system + idle + iowait + irq + softirq))
        idle1=$idle
        sleep 0.1
        read -r cpu user nice system idle iowait irq softirq < /proc/stat
        total2=$((user + nice + system + idle + iowait + irq + softirq))
        idle2=$idle
        CPU=$(( 100 * ( (total2 - total1) - (idle2 - idle1) ) / (total2 - total1) ))
      fi

      # Get RAM usage
      read -r TOTAL AVAIL <<< $(${pkgs.gawk}/bin/awk '/MemTotal/ {total=$2} /MemAvailable/ {avail=$2} END {print total, avail}' /proc/meminfo)
      USED=$((TOTAL - AVAIL))
      USED_GB=$(echo "scale=1; $USED / 1048576" | ${pkgs.bc}/bin/bc)
      TOTAL_GB=$(echo "scale=0; $TOTAL / 1048576" | ${pkgs.bc}/bin/bc)
      RAM_PCT=$((100 * USED / TOTAL))

      printf '{"text": "󰍛", "tooltip": "CPU: %s%%\\nRAM: %sG/%sG (%s%%)"}\n' "$CPU" "$USED_GB" "$TOTAL_GB" "$RAM_PCT"
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
      modules-center = [ "clock" ];
      modules-right = [
        "privacy"
        "tray"
        "bluetooth"
        "network"
        "pulseaudio"
        "pulseaudio#source"
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

      "pulseaudio#source" = {
        format = "{format_source}";
        format-source = "󰍬";
        format-source-muted = "󰍭";
        tooltip-format = "Mic: {source_volume}%";
        on-click-right = "pamixer --default-source -t";
      };

      "custom/sysmon" = {
        exec = "~/.local/bin/waybar-sysmon";
        return-type = "json";
        interval = 5;
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
      #pulseaudio.source,
      #power-profiles-daemon,
      #custom-launcher,
      #custom-nightlight,
      #custom-sysmon,
      #idle_inhibitor,
      #backlight,
      #privacy {
        min-width: 12px;
        margin: 0 7.5px;
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

      #pulseaudio.source.muted {
        color: #6c7086;
      }

      tooltip {
        padding: 2px;
        background-color: alpha(@background, 0.85);
        color: @foreground;
      }
    '';
  };
}
