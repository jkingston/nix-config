# Chromium browser with Wayland touchpad gestures
_:

{
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--enable-features=TouchpadOverscrollHistoryNavigation"
    ];
  };
}
