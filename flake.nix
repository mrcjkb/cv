{
  description = "devShell for LaTeX projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          name = "LaTeX devShell";
          buildInputs = with pkgs;
          with pkgs; [
            # scheme-full, scheme-small, ...
            # See https://nixos.wiki/wiki/TexLive
            alejandra
            texlab
            self.packages.${system}.texlive
            self.packages.${system}.xelatex
            biber
          ];
        };
        packages = rec {
          default = cv-en-detailed;
          cv-en-detailed = pkgs.stdenvNoCC.mkDerivation {
              name = "marcs-cv-en-detailed";
              src = self;
              nativeBuildInputs = [
                xelatex
              ];
              buildPhase = ''
                runHook preBuild
                mkdir -p $out
                xelatex -papersize='A4' -halt-on-error cv_en_detailed.tex
                install -Dm644 cv_en_detailed.pdf -t $out
                runHook postBuild
              '';
          };
          texlive = pkgs.texlive.combine {
            inherit
              (pkgs.texlive)
              moderncv
              geometry
              helvetic
              ragged2e
              relsize
              enumitem
              scheme-small
              academicons
              arydshln
              fontawesome5
              marvosym
              multirow
              ;
          };
          xelatex = with pkgs;
            runCommand "xelatex" {
              nativeBuildInputs = [makeWrapper];
            }
            ''
              mkdir -p $out/bin
              makeWrapper ${self.packages.${system}.texlive}/bin/xelatex $out/bin/xelatex \
                --prefix FONTCONFIG_FILE : ${makeFontsConf {fontDirectories = [lmodern font-awesome_4];}}
            '';
        };
      };
    };
}
