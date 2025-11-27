# nix-config

NixOS flake-based configuration for Framework 12 laptop with Hyprland.

## Project Structure

- `flake.nix` - Main flake with inputs, mkHost function, and nixosConfigurations
- `hosts/<name>/` - Machine-specific configs (hardware, hostname)
- `modules/nixos/` - System-level NixOS modules
- `modules/home/` - Home-manager modules (ui.nix, dev.nix, shell.nix)
- `users/` - User configurations that import home modules
- `scripts/` - Validation scripts (check.sh, lint.sh, fmt.sh)

## Key Patterns

### Adding packages
- System packages: `modules/nixos/common.nix` → `environment.systemPackages`
- User packages: `modules/home/dev.nix` → `home.packages`
- GUI/Hyprland: `modules/home/ui.nix`

### Adding a new host
1. Create `hosts/<name>/default.nix` and `hardware-configuration.nix`
2. Add host config to `hosts` attrset in `flake.nix`
3. Add `nixosConfigurations.<name>` output

### Special arguments
The flake passes `hostCfg` and `username` via `specialArgs` to all modules:
- `hostCfg.hostName` - Machine hostname
- `hostCfg.scale` - HiDPI scaling factor
- `hostCfg.internalMonitor` - Primary display name

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
