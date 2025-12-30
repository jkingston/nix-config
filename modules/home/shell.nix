# Shell configuration - Bash + Starship (Omarchy-style)
_:

{
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;

      historyControl = [ "ignoreboth" ];
      historySize = 32768;
      historyFileSize = 32768;

      shellAliases = {
        # Navigation (Omarchy)
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";

        # Git
        gst = "git status";
        gl = "git pull";
        gp = "git push";

        # NixOS
        rebuild = "sudo nixos-rebuild switch --flake ~/nix-config";

        # Tools
        ff = "fzf --preview 'bat --color=always {}'";
        lg = "lazygit";
        ld = "lazydocker";
        cat = "bat";
      };

      initExtra = ''
        export EDITOR="nvim"
      '';
    };

    # Starship prompt (Omarchy theme)
    starship = {
      enable = true;
      enableBashIntegration = true;
      settings = {
        add_newline = true;
        command_timeout = 200;
        format = "[$directory$git_branch$git_status]($style)$character";

        character = {
          error_symbol = "[✗](bold cyan)";
          success_symbol = "[❯](bold cyan)";
        };

        directory = {
          truncation_length = 2;
          truncation_symbol = "…/";
          repo_root_style = "bold cyan";
          repo_root_format = "[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) ";
        };

        git_branch = {
          format = "[$branch]($style) ";
          style = "italic cyan";
        };

        git_status = {
          format = "[$all_status]($style)";
          style = "cyan";
          ahead = "⇡\${count} ";
          behind = "⇣\${count} ";
          diverged = "⇕⇡\${ahead_count}⇣\${behind_count} ";
          conflicted = " ";
          up_to_date = " ";
          untracked = "? ";
          modified = " ";
          stashed = "";
          staged = "";
          renamed = "";
          deleted = "";
        };
      };
    };

    # Fuzzy finder (Ctrl+R for history, Ctrl+T for files)
    fzf = {
      enable = true;
      enableBashIntegration = true;
    };

    # Smart cd - replaces cd with `z` command
    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    # Cat with syntax highlighting
    bat = {
      enable = true;
    };

    # Modern ls replacement
    eza = {
      enable = true;
      enableBashIntegration = true;
      icons = "auto";
      git = true;
    };
  };
}
