{ pkgs, ... }:

{
  config = {
    home-manager.users.nishal = ./home.nix;
    users.users.nishal = {
      isNormalUser = true;
      home = "/home/nishal";
      createHome = true;
      description = "Nishal Kulkarni";
      extraGroups = [ "networkmanager" "wheel" ];
    };
  };
}