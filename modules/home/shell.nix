{ ... }:

{
  programs.zsh = {
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
      ll = "ls -alh";
      gst = "git status";
      gl = "git pull";
      gp = "git push";
      rebuild = "sudo nixos-rebuild switch --flake ~/nix-config";
    };

    # Optionally set as default shell:
    initContent = ''
      export EDITOR="nvim"
    '';
  };
}
