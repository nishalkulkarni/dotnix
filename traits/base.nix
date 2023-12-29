{ config, pkgs, ... }:

{
  config = {
    # Set your time zone.
    time.timeZone = "Europe/Berlin";
    time.hardwareClockInLocalTime = true;

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    environment.systemPackages = with pkgs; [
      curl
      git
      htop
      neofetch
      pciutils
      tmux
      tree
      vim
      wget
    ];

    sops = {
      defaultSopsFile = ../secrets/secrets.yaml;
      age.keyFile = "/var/lib/sops/age/keys.txt";
      secrets = { cloud_backup_device = { }; };
    };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Experimental Features  
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?
  };
}
