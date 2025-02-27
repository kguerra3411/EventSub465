{
  description = "Dev shell for serverless application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            serverless
            nodejs
            yarn
            python311
            python311Packages.pip
          ];

          shellHook = ''
            echo "Loaded dev shell."
          '';
        };
      }
    );
}
