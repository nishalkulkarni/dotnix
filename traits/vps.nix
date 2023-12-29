{ config, pkgs, ... }:

{
  config = {
    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Enable networking
    networking.networkmanager.enable = true;

    # Open ports in the firewall.
    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = [ 22 ];
    networking.firewall.allowedUDPPorts = [ 22 ];

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable the OpenSSH daemon.  
    services.openssh = {
      enable = true;
      # require public key authentication for better security
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
      settings.PermitRootLogin = "no";
    };

    # Setup passwordless sudo
    security.sudo.wheelNeedsPassword = false;

    # Storage
    environment.systemPackages = with pkgs; [ cifs-utils ];
    fileSystems."/mnt/storage" = {
      device = builtins.readFile config.sops.secrets.cloud_backup_device.path;
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts =
          "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in [ "${automount_opts},credentials=/etc/nixos/smb-secrets,rw,mfsymlinks,seal,uid=33,gid=0,file_mode=0770,dir_mode=0770" ];
    };
  };
}
