{
  description = "LLVM development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    devShells = let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      x86_64-linux.default = pkgs.mkShell {

        packages = with pkgs; [ llvmPackages_16.clang llvmPackages_16.llvm ];
      };
    };
  };
}
