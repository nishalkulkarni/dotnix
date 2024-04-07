{
  description = "GNOME development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    devShells = let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      buildDocs = pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform
        && !pkgs.stdenv.hostPlatform.isStatic;

      # Custom gtk4
      custom_gtk4 = pkgs.gtk4.overrideAttrs (oldAttrs: rec {
        pname = "gtk";
        version = "4.13.4";

        src = pkgs.fetchurl {
          url = "https://gitlab.gnome.org/GNOME/${pname}/-/archive/${version}/${pname}-${version}.tar.gz";
          sha256 = "sbt1PwJU2L78g+tzRxDcpi/73FO6QnT718bicD8Ec1s=";
        };

        buildInputs = with pkgs; [
          libxkbcommon
          libpng
          libdrm
          libtiff
          libjpeg
          libepoxy
          isocodes
          gst_all_1.gst-plugins-base
          gst_all_1.gst-plugins-bad
          fribidi
          harfbuzz
          xorg.libICE
          xorg.libSM
          xorg.libXcursor
          xorg.libXdamage
          xorg.libXi
          xorg.libXrandr
          xorg.libXrender
          tracker
          libGL
          wayland
          wayland-protocols
          xorg.libXinerama
          cups
          libexecinfo
        ];
      });

      # Custom gsettings-desktop-schemas
      custom_gds = pkgs.gsettings-desktop-schemas.overrideAttrs (oldAttrs: rec {
        pname = "gsettings-desktop-schemas";
        version = "46.0";

        src = pkgs.fetchurl {
          url = "mirror://gnome/sources/${pname}/${nixpkgs.lib.versions.major version}/${pname}-${version}.tar.xz";
          sha256 = "STpGoRYbY4jVeqcvYyp5zpbELV/70dCwD0luxYdvhXU=";
        };
      });

      # Custom gnome-online-accounts version
      custom_goa = pkgs.gnome-online-accounts.overrideAttrs (oldAttrs: rec {
        pname = "gnome-online-accounts";
        version = "3.49.1";
        src = pkgs.fetchurl {
          url = "mirror://gnome/sources/${pname}/${
              nixpkgs.lib.versions.majorMinor version
            }/${pname}-${version}.tar.xz";
          sha256 = "7dd9be915bc0c7ac84edf1425f8046bb323757913e7eb7a5ab8cfcd39cc50833";
        };

        outputs = [ "out" "dev" ];

        mesonFlags = [
          "-Dfedora=false" # not useful in NixOS or for NixOS users.
        ];

        buildInputs = with pkgs; [
          gcr_4
          glib
          glib-networking
          custom_gtk4
          libadwaita.dev
          gvfs # OwnCloud, Google Drive
          icu
          json-glib
          libkrb5
          librest_1_0
          libxml2
          libsecret
          libsoup_3
        ];
      });

      # Custom glib version
      custom_glib = pkgs.glib.overrideAttrs (oldAttrs: rec {
        version = "2.79.0";
        src = pkgs.fetchurl {
          url = "mirror://gnome/sources/glib/${
              nixpkgs.lib.versions.majorMinor version
            }/glib-${version}.tar.xz";
          sha256 = "1+veVQX1xHQaBP/jL2knvRZbE8qqvhjpYt3FjIEfhMk=";
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

        preCheck = nixpkgs.lib.optionalString
          oldAttrs.doCheck or nixpkgs.config.doCheckByDefault or false ''
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
          custom_gds
          custom_gtk4.dev
          glib.dev
          custom_goa.dev
          accountsservice.dev
          appstream.dev
          bison
          colord.dev
          colord-gtk4.dev
          curl.dev
          d-spy
          flex
          gcr_4.dev
          gexiv2.dev
          gnome-desktop.dev
          gnome.adwaita-icon-theme
          gnome.gnome-bluetooth.dev
          gnome.gnome-settings-daemon
          gnome-tecla
          gsound
          gst_all_1.gstreamer.dev
          gst_all_1.gst-plugins-base.dev
          gst_all_1.gst-plugins-bad.dev
          ibus.dev
          json-glib.dev
          libadwaita.dev
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
          sassc
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
