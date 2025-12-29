# Desktop UI packages
{
  pkgs,
  gazelle,
  ...
}:

{
  home.packages =
    with pkgs;
    [
      # Core UI tools
      wvkbd
      localsend

      # Utilities
      xorg.xrdb # for loading .Xresources (XWayland DPI)
      bluez # for bluetooth
      grimblast # for screenshots
      hyprpicker # for color picker
      btop # system monitor
      swayosd # OSD for volume/brightness

      # TUI managers (Omarchy style)
      bluetui # Bluetooth TUI

      # Misc
      nautilus # file manager

      # Media control (Omarchy)
      playerctl
      brightnessctl

      # Dev tools (Omarchy)
      lazydocker
    ]
    ++ [
      gazelle.packages.${pkgs.system}.default # WiFi TUI
    ];

  # Gazelle - modern NetworkManager TUI (replaces nmtui)
  programs.gazelle.enable = true;
}
