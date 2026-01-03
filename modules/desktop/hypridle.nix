# Hypridle automatic screen locking (disabled for VMs)
{
  lib,
  hostCfg,
  ...
}:

{
  services.hypridle = lib.mkIf (!hostCfg.isVM) {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on && systemctl --user restart waybar";
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
}
