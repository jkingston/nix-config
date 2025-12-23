#!/usr/bin/env bash
set -euo pipefail

# Unified NixOS install script
# Run from NixOS minimal installer as root

[[ $EUID -eq 0 ]] || {
  echo "Error: Run as root"
  exit 1
}

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <hostname>"
  echo ""
  echo "Available hosts:"
  echo "  framework12  - Framework 13 laptop (LUKS)"
  echo "  minipc       - Beelink SER5 Pro (LUKS)"
  echo "  vm-aarch64   - UTM VM (no LUKS)"
  exit 1
fi

HOST="$1"
REPO_URL="https://github.com/jkingston/nix-config.git"
USERNAME="jack"

# Validate host
case "$HOST" in
framework12 | minipc | vm-aarch64) ;;
*)
  echo "Error: Unknown host '$HOST'"
  exit 1
  ;;
esac

# Detect LUKS based on hostname
[[ "$HOST" == *vm* ]] && USES_LUKS=false || USES_LUKS=true

echo "=== NixOS Installation for $HOST ==="
echo ""
echo "WARNING: This will ERASE the disk!"
read -rp "Press Enter to continue or Ctrl+C to cancel..."

# Prompt for password
echo ""
echo "Enter password for user '$USERNAME'"
$USES_LUKS && echo "(Also used for disk encryption)"
echo ""

while true; do
  read -rs -p "Password: " PASSWORD
  echo
  read -rs -p "Confirm: " PASSWORD_CONFIRM
  echo

  [[ "$PASSWORD" == "$PASSWORD_CONFIRM" ]] && break
  echo "Passwords don't match. Try again."
  echo ""
done

# Clone config
echo ""
echo "Cloning configuration..."
nix-shell -p git --run "git clone $REPO_URL /tmp/nix-config"
cd /tmp/nix-config

# Create LUKS password file
if $USES_LUKS; then
  echo "$PASSWORD" >/tmp/disk-password
  chmod 600 /tmp/disk-password
fi

# Run disko
echo ""
echo "Running disko..."
nix run github:nix-community/disko -- --mode disko --flake ".#$HOST"

# Install NixOS
echo ""
echo "Installing NixOS..."
nixos-install --flake ".#$HOST" --no-root-passwd

# Set user password
echo ""
echo "Setting user password..."
echo "$USERNAME:$PASSWORD" | nixos-enter --root /mnt -c 'chpasswd'

# Cleanup
$USES_LUKS && rm -f /tmp/disk-password

echo ""
echo "=== Installation complete! ==="
echo ""
echo "Run 'reboot' to boot into NixOS"
echo ""
if $USES_LUKS; then
  echo "First boot notes:"
  echo "- Enter your disk encryption password at boot"
fi
echo "- Auto-login is enabled (no login screen)"
echo "- Your password is needed for sudo and screen unlock"
