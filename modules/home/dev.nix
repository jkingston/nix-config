{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    gh
    direnv
    nix-direnv
    neovim
    jq
    ripgrep
    fd
    unzip
    tree
  ];

  programs = {
    git = {
      enable = true;
      userName = "Jack Kingston"; # remember to swap these later
      userEmail = "j.kngstn@gmail.com";

      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = false;

        core = {
          pager = "delta";
        };

        delta = {
          navigate = true;
        };
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    ssh.enable = true;
  };

  # Optionally configure Neovim here or in its own module
}
