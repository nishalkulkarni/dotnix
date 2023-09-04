{ config, pkgs, ... }:

{
  home.username = "nishal";
  home.homeDirectory = "/home/nishal";
  
  home.packages = with pkgs; [
    discord
    element-desktop
    firefox
    gimp
    google-chrome
    hunspell
    hunspellDicts.en_US
    libreoffice-qt
    signal-desktop
    spotify
    vscode
  ];

  programs.bash = {
    enable = true;
    initExtra = ''
      eval "$(direnv hook bash)"
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
