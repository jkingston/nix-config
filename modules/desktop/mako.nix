# Mako notification daemon configuration
_:

{
  services.mako = {
    enable = true;
    settings = {
      # Omarchy style (square corners, wider)
      anchor = "top-right";
      width = 420;
      padding = "10,15";
      margin = "20";
      border-size = 2;
      border-radius = 0; # Square corners
      default-timeout = 5000;
      max-visible = 5;
      layer = "overlay";
      icons = true;
      max-icon-size = 32;
      font = "sans-serif 14";
    };
  };
}
