{ config, pkgs, ... }:

{
  home.username = "nishal";
  home.homeDirectory = "/home/nishal";

  programs.bash = {
    enable = true;
    initExtra = ''
      eval "$(direnv hook bash)"
      export PATH="$PATH:$HOME/Projects/scripts"
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      export PATH="$PATH:$HOME/Projects/scripts"
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "direnv" ];
      theme = "robbyrussell";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.home-manager.enable = true;

  home.stateVersion = "23.05";
}
