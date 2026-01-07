# NixOS system updates checker for waybar
{ config, pkgs, ... }:

{
  # Full update check with nvd - caches results for 4 hours
  home.file.".local/bin/nixos-updates-check" = {
    text = ''
      #!/usr/bin/env bash
      # Full update check with nvd - caches results for 4 hours

      CACHE_DIR="$HOME/.cache/nixos-updates"
      CACHE_FILE="$CACHE_DIR/status.json"
      LAST_CHECK="$CACHE_DIR/last-check"
      LOCK_FILE="$CACHE_DIR/check.lock"
      CHECK_INTERVAL=14400  # 4 hours

      mkdir -p "$CACHE_DIR"

      # If auto-check is disabled, show disabled state
      if [ -f "$CACHE_DIR/disabled" ]; then
        echo '{"text": "󰏤", "tooltip": "Auto-check disabled", "class": "disabled"}'
        exit 0
      fi

      # If check already in progress, return cached result or spinner
      if [ -f "$LOCK_FILE" ]; then
        if [ -f "$CACHE_FILE" ]; then
          cat "$CACHE_FILE"
        else
          echo '{"text": "󰑓", "tooltip": "Checking for updates...", "class": "checking"}'
        fi
        exit 0
      fi

      # Return cached result if recent
      if [ -f "$LAST_CHECK" ] && [ -f "$CACHE_FILE" ]; then
        AGE=$(($(date +%s) - $(cat "$LAST_CHECK")))
        if [ $AGE -lt $CHECK_INTERVAL ]; then
          cat "$CACHE_FILE"
          exit 0
        fi
      fi

      # Acquire exclusive lock (non-blocking)
      exec 9>"$LOCK_FILE"
      ${pkgs.util-linux}/bin/flock -n 9 || {
        [ -f "$CACHE_FILE" ] && cat "$CACHE_FILE"
        exit 0
      }
      trap "rm -f $LOCK_FILE" EXIT

      # Skip check if repo has uncommitted changes
      if ! ${pkgs.git}/bin/git -C "$HOME/nix-config" diff --quiet || ! ${pkgs.git}/bin/git -C "$HOME/nix-config" diff --cached --quiet; then
        echo '{"text": "󰏫", "tooltip": "Uncommitted changes - commit first", "class": "dirty"}'
        exit 0
      fi

      # Clone flake to temp directory (git clone preserves .git for github: inputs)
      TEMP_DIR=$(mktemp -d)
      trap "rm -rf $TEMP_DIR; rm -f $LOCK_FILE" EXIT

      if ! ${pkgs.git}/bin/git clone --depth 1 --quiet "$HOME/nix-config" "$TEMP_DIR" 2>/dev/null; then
        echo '{"text": "󰀦", "tooltip": "Clone failed", "class": "error"}' | tee "$CACHE_FILE"
        date +%s > "$LAST_CHECK"
        exit 0
      fi

      cd "$TEMP_DIR"

      # Update flake inputs (2 min timeout)
      if ! ${pkgs.coreutils}/bin/timeout 120 nix flake update 2>/dev/null; then
        echo '{"text": "󰀦", "tooltip": "Update check failed", "class": "error"}' | tee "$CACHE_FILE"
        date +%s > "$LAST_CHECK"
        exit 0
      fi

      # Build new system (10 min timeout)
      HOSTNAME=$(hostname)
      if ! ${pkgs.coreutils}/bin/timeout 600 nix build ".#nixosConfigurations.$HOSTNAME.config.system.build.toplevel" 2>/dev/null; then
        echo '{"text": "󰀦", "tooltip": "Build failed", "class": "error"}' | tee "$CACHE_FILE"
        date +%s > "$LAST_CHECK"
        exit 0
      fi

      # Count package updates with nvd
      UPDATES=$(${pkgs.nvd}/bin/nvd diff /run/current-system ./result 2>/dev/null | grep -cE '^\[U\]' || echo 0)

      if [ "$UPDATES" -gt 0 ]; then
        printf '{"text": "󰚰 %d", "tooltip": "%d package updates available", "class": "has-updates"}\n' "$UPDATES" "$UPDATES" | tee "$CACHE_FILE"
      else
        echo '{"text": "󰄬", "tooltip": "System up to date", "class": "current"}' | tee "$CACHE_FILE"
      fi

      date +%s > "$LAST_CHECK"
    '';
    executable = true;
  };

  # Interactive update script (left-click)
  home.file.".local/bin/nixos-update" = {
    text = ''
      #!/usr/bin/env bash
      set -e
      cd ~/nix-config || exit 1

      echo "=== NixOS System Update ==="
      echo ""

      # Check for uncommitted changes
      if ! git diff --quiet || ! git diff --cached --quiet; then
        echo "ERROR: Uncommitted changes detected."
        echo "Please commit or stash your changes first."
        echo ""
        git status --short
        echo ""
        read -p "Press Enter to close..."
        exit 1
      fi

      # Check for untracked files that matter
      if [ -n "$(git ls-files --others --exclude-standard)" ]; then
        echo "WARNING: Untracked files present (will be ignored)"
        git ls-files --others --exclude-standard
        echo ""
      fi

      # Sync with remote
      echo "Syncing with remote..."
      git fetch origin
      LOCAL=$(git rev-parse HEAD)
      REMOTE=$(git rev-parse origin/main)
      BASE=$(git merge-base HEAD origin/main)

      if [ "$LOCAL" != "$REMOTE" ]; then
        if [ "$LOCAL" = "$BASE" ]; then
          echo "Remote is ahead, pulling..."
          git pull --rebase origin main
        elif [ "$REMOTE" = "$BASE" ]; then
          echo "Local is ahead of remote."
        else
          echo "ERROR: Local and remote have diverged."
          echo "Please resolve manually with: git pull --rebase"
          read -p "Press Enter to close..."
          exit 1
        fi
      else
        echo "Already in sync with remote."
      fi

      echo ""
      echo "Updating flake inputs..."
      nix flake update

      echo ""
      echo "Building new configuration..."
      nixos-rebuild build --flake . 2>&1

      if [ -d result ]; then
        echo ""
        echo "=== Package Changes ==="
        ${pkgs.nvd}/bin/nvd diff /run/current-system ./result
        echo ""
        read -p "Apply this update? [y/N] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          sudo nixos-rebuild switch --flake .

          # Commit and push
          echo ""
          echo "Committing flake.lock..."
          git add flake.lock
          git commit -m "chore: update flake inputs"
          git push origin main

          # Clear update cache
          rm -f ~/.cache/nixos-updates/last-check
          pkill -RTMIN+12 waybar || true

          echo ""
          echo "Update complete!"
        else
          echo "Update cancelled, reverting flake.lock..."
          git checkout flake.lock
        fi
        rm -f result
      else
        echo "Build failed, reverting flake.lock..."
        git checkout flake.lock
      fi

      echo ""
      read -p "Press Enter to close..."
    '';
    executable = true;
  };

  # Rofi menu for update options (right-click)
  home.file.".local/bin/nixos-update-menu" = {
    text = ''
      #!/usr/bin/env bash
      CHOICE=$(echo -e "Check now\nToggle auto-check" | rofi -dmenu -p "Updates")

      case "$CHOICE" in
        "Check now")
          rm -f ~/.cache/nixos-updates/last-check
          pkill -RTMIN+12 waybar
          notify-send -t 2000 "Checking for updates..."
          ;;
        "Toggle auto-check")
          if [ -f ~/.cache/nixos-updates/disabled ]; then
            rm ~/.cache/nixos-updates/disabled
            notify-send -t 2000 "Update checking enabled"
          else
            mkdir -p ~/.cache/nixos-updates
            touch ~/.cache/nixos-updates/disabled
            notify-send -t 2000 "Update checking disabled"
          fi
          pkill -RTMIN+12 waybar
          ;;
      esac
    '';
    executable = true;
  };
}
