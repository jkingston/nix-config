_:

{
  programs = {
    zsh = {
      enable = true;

      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        theme = "agnoster";
        plugins = [
          "git"
          "sudo"
          "direnv"
        ];
      };

      shellAliases = {
        # Git
        gst = "git status";
        gl = "git pull";
        gp = "git push";

        # NixOS
        rebuild = "sudo nixos-rebuild switch --flake ~/nix-config";

        # Omarchy shell tools
        ff = "fzf --preview 'bat --color=always {}'";
        lg = "lazygit";
        ld = "lazydocker";
        cat = "bat";
      };

      initContent = ''
        export EDITOR="nvim"
      '';
    };

    # Fuzzy finder (Ctrl+R for history, Ctrl+T for files)
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    # Smart cd - replaces cd with `z` command
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    # Cat with syntax highlighting
    bat = {
      enable = true;
    };

    # Modern ls replacement
    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };
  };
}
