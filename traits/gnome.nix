{ config, pkgs, ... }:

{
  config = {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    environment.systemPackages = with pkgs; [
      dconf-editor
      gnomeExtensions.appindicator
      gnome-tweaks
      gnome-software
    ];

    services.udev.packages = with pkgs; [ gnome-settings-daemon ];

    programs.dconf.enable = true;
  };
}
