{ config, pkgs, stylix, hostCfg, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.enableUnifiedKernelImages = true;
  boot.plymouth.enable = true;

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

  # Stylix shared between hosts; cursor size could still be global
  stylix = {
    enable = true;
    base16Scheme = "catppuccin-mocha";
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/catppuccin/wallpapers/main/landscapes/forest/forest.png";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
    fonts.monospace = [ "JetBrainsMono Nerd Font" ];
    cursor.size = 40;
  };

  system.stateVersion = "25.05";
}

