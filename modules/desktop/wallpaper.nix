# Wallpaper management with swww and waypaper
{
  config,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    swww # wallpaper daemon (CLI-based, no config file needed)
    waypaper # GUI wallpaper picker with gallery view
  ];

  # Random wallpaper script (used by Super+Alt+W and timer)
  home.file.".local/bin/wallpaper-random" = {
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

  # Waypaper config
  xdg.configFile."waypaper/config.ini".text = ''
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

  # Catppuccin wallpaper collections (~386 wallpapers)
  home.file = {
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

  # Wallpaper rotation timer
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
}
