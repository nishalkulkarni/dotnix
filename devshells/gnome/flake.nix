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
        buildDocs = pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform && !pkgs.stdenv.hostPlatform.isStatic;
        newglib = pkgs.glib.overrideAttrs (oldAttrs: rec {
          version = "2.76.6";
          src = pkgs.fetchurl {
            url = "mirror://gnome/sources/glib/${nixpkgs.lib.versions.majorMinor version}/glib-${version}.tar.xz";
            sha256 = "ETauaYfcu2TgvjGXqAGQUg96yrgeK/uTfchcEciqnwQ=";
          };

          postInstall = ''
            moveToOutput "share/glib-2.0" "$dev"
            substituteInPlace "$dev/bin/gdbus-codegen" --replace "$out" "$dev"
            sed -i "$dev/bin/glib-gettextize" -e "s|^gettext_dir=.*|gettext_dir=$dev/share/glib-2.0/gettext|"

            # This file is *included* in gtk3 and would introduce runtime reference via __FILE__.
            sed '1i#line 1 "glib-${version}/include/glib-2.0/gobject/gobjectnotifyqueue.c"' \
              -i "$dev"/include/glib-2.0/gobject/gobjectnotifyqueue.c
            for i in $bin/bin/*; do
              moveToOutput "share/bash-completion/completions/''${i##*/}" "$bin"
            done
            for i in $dev/bin/*; do
              moveToOutput "share/bash-completion/completions/''${i##*/}" "$dev"
            done
          '' + nixpkgs.lib.optionalString (!buildDocs) ''
            cp -r ${nixpkgs.buildPackages.glib.devdoc} $devdoc
          '';

          preCheck = nixpkgs.lib.optionalString oldAttrs.doCheck or nixpkgs.config.doCheckByDefault or false ''
            export LD_LIBRARY_PATH="$NIX_BUILD_TOP/glib-${version}/glib/.libs''${LD_LIBRARY_PATH:+:}$LD_LIBRARY_PATH"
            export TZDIR="${nixpkgs.tzdata}/share/zoneinfo"
            export XDG_CACHE_HOME="$TMP"
            export XDG_RUNTIME_HOME="$TMP"
            export HOME="$TMP"
            export XDG_DATA_DIRS="${nixpkgs.desktop-file-utils}/share:${nixpkgs.shared-mime-info}/share"
            export G_TEST_DBUS_DAEMON="${nixpkgs.dbus}/bin/dbus-daemon"
            export PATH="$PATH:$(pwd)/gobject"
            echo "PATH=$PATH"
          '';
        });
      in {
        x86_64-linux.default = pkgs.mkShell {

          packages = with pkgs; [
            newglib.dev
            accountsservice.dev
            appstream.dev
            bison
            colord.dev
            colord-gtk4.dev
            curl.dev
            dfeet
            flex
            gcr.dev
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
            json-glib.dev
            libadwaita
            libepoxy
            libgtop.dev
            libgudev.dev
            libnma-gtk4.dev
            libpulseaudio.dev
            libpwquality.dev
            libsecret.dev
            libsoup_3.dev
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