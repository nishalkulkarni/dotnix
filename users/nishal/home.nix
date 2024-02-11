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

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.home-manager.enable = true;

  home.stateVersion = "23.05";
}
