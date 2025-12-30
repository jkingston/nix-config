# Core system configuration - locale, nix settings, users, programs
{
  pkgs,
  lib,
  hostCfg,
  username,
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

  # Shared user configuration
  users.users.${username} = {
    isNormalUser = true;
    initialPassword = "nixos";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ]
    ++ lib.optionals hostCfg.isLaptop [ "input" ]
    ++ lib.optionals (!hostCfg.isVM && !hostCfg.isLaptop) [ "render" ];
  };

  services.xserver.enable = false;

  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    uwsm.enable = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Plymouth boot splash (themed by Stylix)
    plymouth.enable = true;

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
      "vt.global_cursor_default=0"
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

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
  ];

  hardware.graphics.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  system.stateVersion = "25.05";
}
