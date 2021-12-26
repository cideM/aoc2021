{
  description = "Advent of Code 2021";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        pkgsX86 = import nixpkgs {
          system = if system == "aarch64-darwin" then "x86_64-darwin" else system;
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            coreutils
            moreutils
            jq

            lua5_4

            pkgsX86.ghcid
            pkgsX86.ormolu
            pkgsX86.hlint

            (haskellPackages.ghcWithPackages
              (pkgs: with pkgs; [
                text
                megaparsec
              ]))
          ];
        };
      }
    );
}
