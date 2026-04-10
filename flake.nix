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
        rev = "0e5d6b3bf96412f492efbc0d34957a662a1adb9e";
      in
      {
        packages.svlangserver = pkgs.buildNpmPackage {
          pname = "svlangserver";
          version = rev;

          src = pkgs.fetchFromGitHub {
            owner = "imc-trading";
            repo  = "svlangserver";
            inherit rev;
            hash = "sha256-E39DIB4XTto3Fv6frgkIlSBIhROfatB9VOURpxBnUfc=";
          };

          npmDepsHash = "sha256-7j9TE1QkqymOWKjE1tSA8n9AJ2nSyjQoDq/8jptIPwY=";


          buildPhase = ''
            runHook preBuild

            # Install deps and build lib/
            npm install --legacy-peer-deps
            npm run build || npm run prepare || true

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            # Copy full built tree (preserving bin/lib layout)
            mkdir -p $out
            cp -r ./* $out/

            # Create launcher
            mkdir -p $out/bin
            cat > $out/bin/svlangserver <<EOF
            #!${pkgs.bash}/bin/bash
            exec ${pkgs.nodejs}/bin/node $out/bin/main.js "$@"

            EOF
            chmod +x $out/bin/svlangserver

            runHook postInstall
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


