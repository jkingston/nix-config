# nix-config

NixOS flake-based configuration for multiple machines with Hyprland.

## Project Structure

```
├── flake.nix              # Main flake with inputs and nixosConfigurations
├── hosts/<name>/
│   ├── default.nix        # Host entry point (imports disko, common modules)
│   ├── disko.nix          # Disk partitioning
│   └── profile.nix        # Machine-specific values (hostname, display, etc.)
├── modules/
│   ├── system/            # NixOS system modules
│   │   ├── core.nix       # Nix settings, locale, users, boot, networking
│   │   ├── greetd.nix     # Login manager
│   │   ├── pipewire.nix   # Audio
│   │   ├── power.nix      # Laptop power management
│   │   ├── stylix.nix     # Wallpaper and font theming
│   │   └── hardware/      # GPU drivers (intel, amd)
│   ├── nixos/
│   │   └── common.nix     # Entry point that imports system modules
│   ├── desktop/           # Home-manager desktop modules
│   │   ├── hyprland.nix   # Window manager
│   │   ├── waybar.nix     # Status bar
│   │   ├── walker.nix     # App launcher
│   │   ├── mako.nix       # Notifications
│   │   ├── hyprlock.nix   # Lock screen
│   │   ├── hypridle.nix   # Idle management
│   │   ├── nightlight.nix # Blue light filter with scheduling
│   │   ├── wallpaper.nix  # swww + waypaper
│   │   ├── clipboard.nix  # Clipboard manager
│   │   └── ...            # chromium, ghostty, wlogout, etc.
│   └── home/              # Home-manager entry points
│       ├── ui.nix         # Imports desktop modules
│       ├── dev.nix        # Dev tools (git, neovim, direnv)
│       └── shell.nix      # Shell config (zsh, fzf, eza)
├── users/
│   └── default-user.nix   # User home config (imports home modules)
└── scripts/               # Validation and install scripts
```

## Key Patterns

### Adding packages
- System packages: `modules/system/core.nix` → `environment.systemPackages`
- Dev tools: `modules/home/dev.nix` → `home.packages`
- Desktop utilities: `modules/desktop/packages.nix` → `home.packages`

### Adding a new desktop feature
1. Create `modules/desktop/feature.nix` with the configuration
2. Add import to `modules/home/ui.nix`

### Adding a new host
1. Create `hosts/<name>/profile.nix` with machine-specific values
2. Create `hosts/<name>/default.nix` and `disko.nix`
3. Add `nixosConfigurations.<name> = mkHost "<name>" ./hosts/<name>/profile.nix;` to flake.nix

### Host profile format
```nix
{
  system = "x86_64-linux";
  hostName = "myhost";
  isLaptop = false;
  isVM = false;
  monitor = { name = "DP-1"; scale = 1.0; };
  hardwareModules = [ ../../modules/system/hardware/amd-graphics.nix ];
  extraModules = [ ];
}
```

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
- Commits: Conventional style (`feat:`, `fix:`, `refactor:`)

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
