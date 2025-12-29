# Greetd login manager configuration
{
  pkgs,
  username,
  ...
}:

{
  services.greetd = {
    enable = true;
    settings = {
      # auto-login, no menu
      default_session = {
        command = "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop";
        user = username;
      };
    };
  };
}
