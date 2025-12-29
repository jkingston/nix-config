# Walker app launcher configuration
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    walker
    libqalculate # calculator backend for walker
  ];

  xdg.configFile = {
    "walker/config.toml".text = ''
      placeholder = "Search..."
      fullscreen = false
      ssh_host_file = ""
      terminal = "ghostty"

      [search]
      delay = 0
      hide_icons = false

      [activation_mode]
      disabled = true

      [builtins.applications]
      weight = 5
      name = "applications"
      placeholder = "Applications"

      [builtins.runner]
      weight = 4
      name = "runner"

      [builtins.websearch]
      weight = 1
      name = "websearch"

      [builtins.calc]
      weight = 3

      [builtins.clipboard]
      weight = 4
      max_entries = 50

      [builtins.emojis]
      weight = 2
    '';

    "walker/style.css".text = ''
      /* Catppuccin Mocha */
      @define-color base #1e1e2e;
      @define-color surface0 #313244;
      @define-color surface1 #45475a;
      @define-color text #cdd6f4;
      @define-color subtext0 #a6adc8;
      @define-color blue #89b4fa;

      window {
        background-color: alpha(@base, 0.95);
        border-radius: 12px;
        border: 1px solid @surface0;
      }

      #box {
        margin: 10px;
      }

      #search {
        background-color: @surface0;
        color: @text;
        border-radius: 8px;
        padding: 10px 14px;
        font-size: 14px;
      }

      #list {
        background: transparent;
        margin-top: 10px;
      }

      row {
        padding: 8px 12px;
        border-radius: 6px;
      }

      row:selected {
        background-color: @surface1;
      }

      row label {
        color: @text;
      }

      row:selected label {
        color: @blue;
      }
    '';
  };
}
