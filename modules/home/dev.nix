{ pkgs, ... }:

{
  # Note: claude-code overlay is applied at system level in flake.nix
  # (required when using home-manager.useGlobalPkgs = true)

  home.packages = with pkgs; [
    git
    gh
    delta
    direnv
    nix-direnv
    jq
    ripgrep
    fd
    unzip
    tree
    claude-code

    # Shell tools (Omarchy)
    lazygit

    # System monitoring
    ncdu # disk usage analyzer
    duf # modern df
    procs # modern ps
    tldr # simplified man pages
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

    # Neovim with LazyVim
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
