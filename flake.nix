{
  description = "NixOS system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, home-manager, sops-nix }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in {
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              cmake
              gcc13
              meson
              ninja
              nixpkgs-fmt
              python311
              gdb
            ];

            shellHook = ''
              printf "Welcome to devshell\n"
            '';
          };
        });

      nixosConfigurations = let
        x86_64Base = {
          system = "x86_64-linux";
          modules = with self.nixosModules; [
            ({ config = { nix.registry.nixpkgs.flake = nixpkgs; }; })
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            traits.base
          ];
        };
        aarch64Base = {
          system = "aarch64-linux";
          modules = with self.nixosModules; [
            ({ config = { nix.registry.nixpkgs.flake = nixpkgs; }; })
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            traits.base
          ];
        };
      in with self.nixosModules; {
        # Lenovo Legion Y540
        legion = nixpkgs.lib.nixosSystem {
          inherit (x86_64Base) system;
          modules = x86_64Base.modules ++ [
            platforms.legion
            traits.workstation
            traits.gnome
            traits.gamestation
            users.nishal
          ];
        };
        # Cloud Arm VPS
        gisela = nixpkgs.lib.nixosSystem {
          inherit (aarch64Base) system;
          modules = aarch64Base.modules
            ++ [ platforms.gisela traits.vps traits.immich traits.paperless users.nishal ];
        };
        # Raspberry Pi Image
        rPiImage = nixpkgs.lib.nixosSystem {
          inherit (aarch64Base) system;
          modules = aarch64Base.modules ++ [
            platforms.rpi
            users.nishal
            {
              config = {
                nixpkgs.config.allowUnsupportedSystem = true;
                nixpkgs.hostPlatform.system = "aarch64-linux";
                nixpkgs.buildPlatform.system = "aarch64-linux";
                # Access temporary wireless network for headless install
                # Not safe
                networking.wireless.networks = {
                  nixTmpWifi = { };
                };
              };
            }
          ];
        };
      };

      nixosModules = {
        platforms.gisela = ./platforms/gisela.nix;
        platforms.legion = ./platforms/legion.nix;
        platforms.rpi =
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix";
        traits.base = ./traits/base.nix;
        traits.gamestation = ./traits/gamestation.nix;
        traits.gnome = ./traits/gnome.nix;
        traits.immich = ./traits/immich.nix;
        traits.nextcloud = ./traits/nextcloud.nix;
        traits.paperless = ./traits/paperless.nix;
        traits.vps = ./traits/vps.nix;
        traits.workstation = ./traits/workstation.nix;
        users.nishal = ./users/nishal;
      };
    };
}
