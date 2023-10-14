{
  description = "GNOME development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    {
      devShells = 
      let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
            inherit system;
        };
      in {
        x86_64-linux.default = pkgs.mkShell {

          packages = with pkgs; [
            accountsservice.dev
            appstream.dev
            bison
            colord.dev
            colord-gtk4.dev
            curl.dev
            dfeet
            flex
            gcr.dev
            glib.dev
            gnome-desktop.dev
            gnome-online-accounts.dev
            gnome.adwaita-icon-theme
            gnome.gnome-bluetooth.dev
            gnome.gnome-settings-daemon
            gsound
            gst_all_1.gstreamer.dev
            gst_all_1.gst-plugins-base.dev
            gst_all_1.gst-plugins-bad.dev
            gtk4.dev
            ibus.dev
            libadwaita
            libepoxy
            libgtop.dev
            libgudev.dev
            libnma-gtk4.dev
            libpulseaudio.dev
            libpwquality.dev
            libsecret.dev
            libstemmer
            libwacom.dev
            libxkbcommon.dev
            libxml2.dev
            libyaml.dev
            modemmanager
            networkmanager.dev
            pkg-config
            polkit.dev
            samba.dev
            udisks.dev
            upower.dev
            valgrind
            wrapGAppsHook
            xorg.libXcursor
            xorg.libXdamage
            xorg.libXi
            xorg.libXrandr
            xorg.libXinerama
          ];
        };
      };
    };
}