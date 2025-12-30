{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    gh
    direnv
    nix-direnv
    jq
    ripgrep
    fd
    unzip
    tree

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
      settings = {
        user = {
          name = "Jack Kingston"; # remember to swap these later
          email = "j.kngstn@gmail.com";
        };

        init.defaultBranch = "main";
        pull.rebase = false;

        core = {
          pager = "delta";
        };

        delta = {
          navigate = true;
        };

        # Use gh CLI for GitHub authentication
        credential."https://github.com".helper = "!gh auth git-credential";
        credential."https://gist.github.com".helper = "!gh auth git-credential";
      };
    };

    delta.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        setEnv.TERM = "xterm-256color";
      };
    };

    # Neovim with LazyVim
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
