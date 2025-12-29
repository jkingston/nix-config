# Desktop utility scripts
_:

{
  home.file = {
    # On-screen keyboard toggle
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
  };
}
