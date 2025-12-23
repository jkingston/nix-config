# nix-config

NixOS flake-based configuration for multiple machines with Hyprland.

## Project Structure

- `flake.nix` - Main flake with inputs, mkHost function, and nixosConfigurations
- `hosts/<name>/` - Machine-specific configs (hardware, hostname)
- `modules/nixos/` - System-level NixOS modules
- `modules/home/` - Home-manager modules (ui.nix, dev.nix, shell.nix)
- `users/` - User configurations that import home modules
- `scripts/` - Validation scripts (check.sh, lint.sh, fmt.sh) and install.sh

## Key Patterns

### Adding packages
- System packages: `modules/nixos/common.nix` → `environment.systemPackages`
- User packages: `modules/home/dev.nix` → `home.packages`
- GUI/Hyprland: `modules/home/ui.nix`

### Adding a new host
1. Create `hosts/<name>/default.nix` and `disko.nix`
2. Add host config to `hosts` attrset in `flake.nix`
3. Add `nixosConfigurations.<name>` output
4. For physical machines, add LUKS to disko.nix (see minipc for example)

### Special arguments
The flake passes `hostCfg` and `username` via `specialArgs` to all modules:
- `hostCfg.hostName` - Machine hostname
- `hostCfg.scale` - HiDPI scaling factor
- `hostCfg.internalMonitor` - Primary display name
- `hostCfg.isLaptop` - Laptop-specific features (power management, lid switch)
- `hostCfg.isVM` - VM detection (defaults false, disables LUKS/hypridle)

## Code Style

- Format: `nixfmt-rfc-style` (run `./scripts/fmt.sh`)
- Lint: `statix` and `deadnix` (run `./scripts/lint.sh`)
- Commits: Conventional style (`feat:`, `fix:`)

## Validation

Before rebuilding, run:
```bash
./scripts/fmt.sh --check  # Check formatting
./scripts/lint.sh         # Lint and dead code
./scripts/check.sh        # Flake check + dry-run build
```

Or use the nix-check skill which runs all three.

## Rebuild Command

```bash
sudo nixos-rebuild switch --flake ~/nix-config
```

Or use the `rebuild` shell alias.

## Installation

For fresh installs, boot the NixOS 25.11+ minimal installer and run:
```bash
git clone https://github.com/jkingston/nix-config.git
cd nix-config
sudo ./scripts/install.sh <hostname>
```

The script prompts for a password (used for both user account and LUKS on physical machines), partitions the disk, and installs NixOS.

### Hosts
- `framework12` - Framework 13 laptop (x86_64, LUKS)
- `minipc` - Beelink SER5 Pro (x86_64, LUKS)
- `vm-aarch64` - UTM VM on Apple Silicon (aarch64, no LUKS)
