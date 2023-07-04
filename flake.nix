{
    description = "NixOS system configuration";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
       home-manager = {
            url = "github:nix-community/home-manager";
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
        nixosConfigurations = {
            nixos = nixpkgs.lib.nixosSystem {
                inherit system;
                modules = [ ./configuration.nix ];
            };

        };         
    };
}
