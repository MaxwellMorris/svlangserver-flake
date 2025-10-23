{
  description = "Nix flake for IMC Trading svlangserver";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.svlangserver = pkgs.stdenv.mkDerivation {
          pname = "svlangserver";
          version = "0.3.5";

          src = pkgs.fetchFromGitHub {
            owner = "imc-trading";
            repo  = "svlangserver";
            rev   = "v0.3.5"; # example commit
            sha256 = "sha256-CkcKyC2W6NBvxkwYDVHpBF5T2NMiiDVVwR1mftEks54="; # fill via nix-prefetch-git
          };

          nativeBuildInputs = [ pkgs.nodejs ];

          buildPhase = ''
            export npm_config_cache=$PWD/.npm
            npm install --legacy-peer-deps
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp bin/main.js $out/bin/svlangserver
            chmod +x $out/bin/svlangserver
          '';

          meta = with pkgs.lib; {
            description = "SystemVerilog Language Server by IMC Trading";
            license = licenses.mit;
            platforms = platforms.all;
          };
        };

        packages.default = self.packages.${system}.svlangserver;

        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.nodejs ];
        };
      });
}
