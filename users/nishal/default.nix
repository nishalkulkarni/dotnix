{ pkgs, ... }:

{
  config = {
    home-manager.users.nishal = ./home.nix;
    users.users.nishal = {
      isNormalUser = true;
      home = "/home/nishal";
      createHome = true;
      description = "Nishal Kulkarni";
      extraGroups = [ "networkmanager" "wheel" "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBrKChenpivEx2Gc1TAHYquIpFLrMd7tLzrZifFpwPle"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICST+P8og7Kw8eCvbSfgrdNqtkbZ6+/PtRMBfM9rfofE"
      ];
    };
  };
}
