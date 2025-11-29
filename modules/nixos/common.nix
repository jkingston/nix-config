{
  pkgs,
  stylix,
  ...
}:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Cachix for pre-built claude-code binaries
    substituters = [ "https://claude-code.cachix.org" ];
    trusted-public-keys = [ "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk=" ];
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";

  # PAM service for hyprlock screen locker
  security.pam.services.hyprlock = { };

  services = {
    xserver.enable = false;

    greetd = {
      enable = true;
      settings = {
        # auto-login, no menu
        default_session = {
          command = "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop";
          user = "jack";
        };
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    libinput.enable = true;
    upower.enable = true;
    dbus.packages = [ pkgs.iio-sensor-proxy ];

    # Let Hyprland handle lid switch (don't let systemd intercept it)
    logind = {
      lidSwitch = "ignore";
      lidSwitchExternalPower = "ignore";
      lidSwitchDocked = "ignore";
    };

    # Framework laptop services
    power-profiles-daemon.enable = true;
    fwupd.enable = true;
  };

  programs = {
    hyprland = {
      enable = true;
      withUWSM = true; # use UWSM, Omarchy-style
      xwayland.enable = true;
    };

    uwsm.enable = true;
  };

  # Catppuccin - primary theming system
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";

    plymouth = {
      enable = true;
      flavor = "mocha";
    };
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Plymouth boot splash
    plymouth = {
      enable = true;
      extraConfig = ''
        ShowDelay=0
        DeviceTimeout=8
      '';
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
      "vt.global_cursor_default=0" # Hide cursor during VT handoff
    ];
  };

  networking = {
    networkmanager.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        53317
      ];
      allowedUDPPorts = [ 53317 ];
    };
  };

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    wl-clipboard
    grim
    slurp
    swappy
  ];

  # Fonts - JetBrainsMono Nerd Font for Waybar icons
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Stylix - only for wallpaper and fonts (catppuccin handles the rest)
  stylix = {
    enable = true;
    autoEnable = false; # Don't auto-theme apps - catppuccin does that

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

  # Intel Xe Graphics (Framework 13th gen)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # VA-API (iHD driver)
      vpl-gpu-rt # QSV runtime
      intel-compute-runtime # OpenCL
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    NIXOS_OZONE_WL = "1"; # Enable Wayland for Chromium/Electron apps
  };

  system.stateVersion = "25.05";
}
