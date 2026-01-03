# Hyprsunset night light with sunrise/sunset scheduling
# Features: three-state toggle, temperature selection with live preview
# Location is automatic based on system timezone
{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    hyprsunset
    sunwait
    bc # For coordinate calculations
    libnotify # For notify-send in toggle/settings scripts
  ];

  # Config directory setup with defaults
  home.activation.hyprsunsetConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/.config/hyprsunset
    [ -f $HOME/.config/hyprsunset/temperature ] || echo "3500" > $HOME/.config/hyprsunset/temperature
  '';

  # Get coordinates from system timezone
  home.file.".local/bin/hyprsunset-coords" = {
    text = ''
      #!/usr/bin/env bash
      # Get coordinates from system timezone using tzdata

      TZ=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "Europe/London")
      TZDIR=$(dirname $(readlink -f /etc/localtime) 2>/dev/null)

      # Look up timezone in zone.tab
      LINE=$(grep -E "[[:space:]]$TZ\$" "$TZDIR/zone.tab" 2>/dev/null | head -1)
      ISO_COORDS=$(echo "$LINE" | awk '{print $2}')

      # Default to London if lookup fails
      if [ -z "$ISO_COORDS" ]; then
        echo "51.5N 0.1W"
        exit 0
      fi

      # Parse ISO 6709 format: +DDMM or +DDMMSS for lat, -DDDMM or -DDDMMSS for lon
      # Example: +513030-0000731 = 51°30'30"N 0°07'31"W

      # Split into lat and lon parts
      # Latitude is first + or - to next + or -
      LAT_SIGN="''${ISO_COORDS:0:1}"
      REST="''${ISO_COORDS:1}"

      # Find where longitude starts (next + or -)
      for i in $(seq 0 $((''${#REST}-1))); do
        CHAR="''${REST:$i:1}"
        if [ "$CHAR" = "+" ] || [ "$CHAR" = "-" ]; then
          LAT_NUM="''${REST:0:$i}"
          LON_SIGN="$CHAR"
          LON_NUM="''${REST:$((i+1))}"
          break
        fi
      done

      # Parse latitude (DDMM or DDMMSS)
      if [ ''${#LAT_NUM} -le 4 ]; then
        LAT_DEG="''${LAT_NUM:0:2}"
        LAT_MIN="''${LAT_NUM:2:2}"
        LAT_SEC=0
      else
        LAT_DEG="''${LAT_NUM:0:2}"
        LAT_MIN="''${LAT_NUM:2:2}"
        LAT_SEC="''${LAT_NUM:4:2}"
      fi

      # Parse longitude (DDDMM or DDDMMSS)
      if [ ''${#LON_NUM} -le 5 ]; then
        LON_DEG="''${LON_NUM:0:3}"
        LON_MIN="''${LON_NUM:3:2}"
        LON_SEC=0
      else
        LON_DEG="''${LON_NUM:0:3}"
        LON_MIN="''${LON_NUM:3:2}"
        LON_SEC="''${LON_NUM:5:2}"
      fi

      # Remove leading zeros for bc
      LAT_DEG=$((10#$LAT_DEG))
      LAT_MIN=$((10#$LAT_MIN))
      LAT_SEC=$((10#$LAT_SEC))
      LON_DEG=$((10#$LON_DEG))
      LON_MIN=$((10#$LON_MIN))
      LON_SEC=$((10#$LON_SEC))

      # Calculate decimal degrees
      LAT=$(echo "scale=2; $LAT_DEG + $LAT_MIN/60 + $LAT_SEC/3600" | ${pkgs.bc}/bin/bc)
      LON=$(echo "scale=2; $LON_DEG + $LON_MIN/60 + $LON_SEC/3600" | ${pkgs.bc}/bin/bc)

      # Determine direction
      LAT_DIR="N"
      [ "$LAT_SIGN" = "-" ] && LAT_DIR="S"
      LON_DIR="E"
      [ "$LON_SIGN" = "-" ] && LON_DIR="W"

      echo "''${LAT}''${LAT_DIR} ''${LON}''${LON_DIR}"
    '';
    executable = true;
  };

  # Hyprsunset gradual transition script (30 min fade)
  home.file.".local/bin/hyprsunset-transition" = {
    text = ''
      #!/usr/bin/env bash
      # Gradual transition between day/night over 30 minutes
      # Usage: hyprsunset-transition day|night

      # Skip if manual override is active
      [ -f /tmp/hyprsunset-auto ] && exit 0

      CONFIG_DIR="$HOME/.config/hyprsunset"
      NIGHT_TEMP=$(cat "$CONFIG_DIR/temperature" 2>/dev/null || echo "3500")
      COORDS=$(~/.local/bin/hyprsunset-coords)

      MODE="$1"
      STEPS=30
      STEP_DURATION=60  # 60 seconds per step

      DAY_TEMP=6500

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

  # Hyprsunset waybar toggle (three-state cycle: Auto -> On -> Off -> Auto)
  home.file.".local/bin/hyprsunset-toggle" = {
    text = ''
      #!/usr/bin/env bash
      # Cycle through: Auto -> On -> Off -> Auto

      CONFIG_DIR="$HOME/.config/hyprsunset"
      TEMP=$(cat "$CONFIG_DIR/temperature" 2>/dev/null || echo "3500")
      COORDS=$(~/.local/bin/hyprsunset-coords)

      STATE_FILE="/tmp/hyprsunset-night"
      AUTO_FILE="/tmp/hyprsunset-auto"

      if [ ! -f "$AUTO_FILE" ]; then
        # Auto -> On: Force night mode
        touch "$AUTO_FILE"
        touch "$STATE_FILE"
        hyprctl hyprsunset temperature "$TEMP"
        notify-send -t 1500 "Night Light: On"
      elif [ -f "$STATE_FILE" ]; then
        # On -> Off: Force day mode
        rm "$STATE_FILE"
        hyprctl hyprsunset identity
        notify-send -t 1500 "Night Light: Off"
      else
        # Off -> Auto: Resume schedule
        rm "$AUTO_FILE"
        # Check if it should be night based on current time
        if ${pkgs.sunwait}/bin/sunwait poll $COORDS; then
          # Daytime - keep day mode
          :
        else
          # Nighttime - apply night mode
          touch "$STATE_FILE"
          hyprctl hyprsunset temperature "$TEMP"
        fi
        notify-send -t 1500 "Night Light: Auto"
      fi

      pkill -SIGRTMIN+10 waybar
    '';
    executable = true;
  };

  # Hyprsunset status script for waybar (JSON output with tooltip)
  home.file.".local/bin/hyprsunset-status" = {
    text = ''
      #!/usr/bin/env bash
      # Output JSON for waybar tooltip with sun times and current state

      CONFIG_DIR="$HOME/.config/hyprsunset"
      TEMP=$(cat "$CONFIG_DIR/temperature" 2>/dev/null || echo "3500")
      TZ=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "Europe/London")
      COORDS=$(~/.local/bin/hyprsunset-coords)

      # State files
      STATE_FILE="/tmp/hyprsunset-night"
      AUTO_FILE="/tmp/hyprsunset-auto"

      # Determine mode
      if [ -f "$AUTO_FILE" ]; then
        if [ -f "$STATE_FILE" ]; then
          MODE="on"
        else
          MODE="off"
        fi
      else
        MODE="auto"
      fi

      # Icon based on current night state
      if [ -f "$STATE_FILE" ]; then
        ICON="󱩌"
      else
        ICON="󰹏"
      fi

      # Parse daylight times correctly from sunwait report
      # Format: "Day with twilight: 08:03 to 16:03"
      DAYLIGHT=$(${pkgs.sunwait}/bin/sunwait report $COORDS | grep "Day with twilight" | sed 's/.*: //')
      SUNRISE=$(echo "$DAYLIGHT" | awk '{print $1}')
      SUNSET=$(echo "$DAYLIGHT" | awk '{print $3}')

      # Output JSON for waybar
      printf '{"text": "%s", "tooltip": "Mode: %s\\n%s\\nTemp: %sK\\n☀️ %s  🌙 %s"}' "$ICON" "$MODE" "$TZ" "$TEMP" "$SUNRISE" "$SUNSET"
    '';
    executable = true;
  };

  # Settings menu (right-click) - temperature only, location is automatic
  home.file.".local/bin/hyprsunset-settings" = {
    text = ''
      #!/usr/bin/env bash
      # Temperature settings - location is automatic from system timezone
      ~/.local/bin/hyprsunset-temp-picker
      pkill -SIGRTMIN+10 waybar
    '';
    executable = true;
  };

  # Temperature picker with live preview
  home.file.".local/bin/hyprsunset-temp-picker" = {
    text = ''
            #!/usr/bin/env bash
            # Temperature picker with live preview

            CONFIG_DIR="$HOME/.config/hyprsunset"
            PREV_TEMP=$(cat "$CONFIG_DIR/temperature" 2>/dev/null || echo "3500")
            LAST_VALUE=""

            MENU="Extreme (1000K)
      Candle (1500K)
      Ember (2000K)
      Warm (2500K)
      Cozy (3000K)
      Soft (3500K)
      Reading (4000K)
      Mild (4500K)"

            # Show rofi, apply on each selection
            while true; do
              SELECTED=$(echo "$MENU" | rofi -dmenu -p "Temperature (ESC to cancel)" -i)

              if [ -z "$SELECTED" ]; then
                # ESC pressed - revert to previous
                if [ -f /tmp/hyprsunset-night ]; then
                  hyprctl hyprsunset temperature "$PREV_TEMP"
                fi
                break
              fi

              # Extract temperature value from selection
              VALUE=$(echo "$SELECTED" | grep -oP '\d+(?=K)')

              if [ -n "$VALUE" ]; then
                # Apply live preview
                hyprctl hyprsunset temperature "$VALUE"

                # Save and exit on second selection of same value (confirm)
                if [ "$VALUE" = "$LAST_VALUE" ]; then
                  echo "$VALUE" > "$CONFIG_DIR/temperature"
                  notify-send -t 1500 "Temperature: ''${VALUE}K"
                  exit 0
                fi
                LAST_VALUE="$VALUE"
              fi
            done
    '';
    executable = true;
  };

  # Sunrise transition - gradual fade to day mode
  systemd.user.services.hyprsunset-day = {
    Unit.Description = "Gradual transition to day mode at sunrise";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "hyprsunset-day" ''
        # Get coordinates from system timezone
        COORDS=$(${config.home.homeDirectory}/.local/bin/hyprsunset-coords)
        # Wait for sunrise
        ${pkgs.sunwait}/bin/sunwait sun up $COORDS
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
        # Get coordinates from system timezone
        COORDS=$(${config.home.homeDirectory}/.local/bin/hyprsunset-coords)
        # Wait for sunset
        ${pkgs.sunwait}/bin/sunwait sun down $COORDS
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
}
