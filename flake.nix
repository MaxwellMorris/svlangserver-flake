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
        SHA256 = "sha256-lOIqKCSvgpVBZwUy49CeReK9e0dHWWV8hmD5BsUJlys=";
      in
      {
        packages.svlangserver = pkgs.buildNpmPackage {
          pname = "svlangserver";
          version = "master";

          src = pkgs.fetchFromGitHub {
            owner = "imc-trading";
            repo  = "svlangserver";
            rev = "master";
            sha256 = "sha256-lOIqKCSvgpVBZwUy49CeReK9e0dHWWV8hmD5BsUJlys=";
          };

          npmDepsHash = "sha256-7j9TE1QkqymOWKjE1tSA8n9AJ2nSyjQoDq/8jptIPwY=";

          installPhase = ''
            mkdir -p $out/lib/svlangserver
            cp -r . $out/lib/svlangserver
            mkdir -p $out/bin
            cat > $out/bin/svlangserver <<EOF
            #!${pkgs.bash}/bin/bash
            exec ${pkgs.nodejs}/bin/node $out/lib/svlangserver/bin/main.js "\$@"
            EOF
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



