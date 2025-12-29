# Hyprsunset night light with sunrise/sunset scheduling
{
  config,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    hyprsunset
    sunwait
  ];

  # Hyprsunset gradual transition script (30 min fade)
  home.file.".local/bin/hyprsunset-transition" = {
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
  home.file.".local/bin/hyprsunset-toggle" = {
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
}
