{
  description = "Web development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    devShells = let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      custom_nodejs = pkgs.nodejs.overrideAttrs (oldAttrs: rec {
        enableNpm = true;
        pname = if enableNpm then "nodejs" else "nodejs-slim";
        version = "20.12.1";

        src = pkgs.fetchurl {
          url = "https://nodejs.org/dist/v${version}/node-v${version}.tar.xz";
          sha256 = "aEDUkLpNHVFlXg++EgmVahXbQFUQ1+oWa62YqMnTek4=";
        };
      });
    in {
      x86_64-linux.default = pkgs.mkShell {

        packages = with pkgs; [ nodejs ];
      };
    };
  };
}
