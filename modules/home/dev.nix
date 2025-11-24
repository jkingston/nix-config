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

  programs.git = {
    enable = true;
    userName = "YOUR NAME";     # you can override via HM per-host or in default-user.nix
    userEmail = "you@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      pager = "delta";
      delta.navigate = true;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.ssh.enable = true;

  # Optionally configure Neovim here or in its own module
}

