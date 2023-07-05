{
    description = "NixOS system configuration";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
       home-manager = {
            url = "github:nix-community/home-manager/release-23.05";
            inputs.nixpkgs.follows = "nixpkgs";
       };
    };

    outputs = { self, nixpkgs, home-manager }: 
    let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
        };
    in {
        nixosConfigurations =
        let
            x86_64Base = {
                system = "x86_64-linux";
                modules = with self.nixosModules; [
                    ({ config = { nix.registry.nixpkgs.flake = nixpkgs; }; })
                    home-manager.nixosModules.home-manager
                    traits.base
                ];
            };
        in
        with self.nixosModules; {
            legion = nixpkgs.lib.nixosSystem {
                inherit (x86_64Base) system;
                modules = x86_64Base.modules ++ [ 
                    platforms.legion
                    traits.workstation
                    traits.gnome
                    users.nishal
                ];
            };

        };

        nixosModules = {
            platforms.legion = ./platforms/legion.nix;
            traits.base = ./traits/base.nix;
            traits.gnome = ./traits/gnome.nix;
            traits.workstation = ./traits/workstation.nix;
            users.nishal = ./users/nishal;
        };
    };
}
