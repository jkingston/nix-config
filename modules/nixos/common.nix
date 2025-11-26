{ config, pkgs, stylix, hostCfg, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";

  services.xserver.enable = false;
  
  services.greetd = {
    enable = true;
    settings = {
      # auto-login, no menu
      default_session = {
        command = "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop";
	user = "jack";
      };
    };
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;        # use UWSM, Omarchy-style
    xwayland.enable = true;
  };

  programs.uwsm.enable = true;

  # Catppuccin - primary theming system
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Plymouth with catppuccin theme (via catppuccin/nix)
    plymouth = {
      enable = true;
      catppuccin = {
        enable = true;
        flavor = "mocha";
      };
    };

    # Enable systemd in initrd for graphical LUKS prompt
    initrd.systemd.enable = true;

    # Silent boot for clean experience
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
  };

  networking.networkmanager.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;
  services.upower.enable = true;
  services.dbus.packages = [ pkgs.iio-sensor-proxy ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 53317 ];
    allowedUDPPorts = [ 53317 ];
  };

  environment.systemPackages = with pkgs; [
    git wget curl
    wl-clipboard grim slurp swappy
  ];

  # Stylix - only for wallpaper and fonts (catppuccin handles the rest)
  stylix = {
    enable = true;
    autoEnable = false;  # Don't auto-theme apps - catppuccin does that

    # Color scheme still needed for Stylix internals
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    # Wallpaper (catppuccin/nix doesn't handle this)
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/forrest.png";
      sha256 = "sha256-jDqDj56e9KI/xgEIcESkpnpJUBo6zJiAq1AkDQwcHQM=";
    };

    # Fonts (catppuccin/nix doesn't handle this)
    fonts.monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
    };

    overlays.enable = false;
  };

  system.stateVersion = "25.05";
}

