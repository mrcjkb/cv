{
  description = "devShell for LaTeX projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    inherit (nixpkgs) lib;
    foreach = xs: f:
      with lib;
        foldr recursiveUpdate {} (
          if isList xs
          then map f xs
          else if isAttrs xs
          then mapAttrsToList f xs
          else throw "foreach: expected list or attrset but got ${typeOf xs}"
        );
  in
    foreach nixpkgs.legacyPackages (
      system: pkgs: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        legacyPackages.${system} = pkgs;
        devShells.${system}.default = pkgs.mkShell {
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
        packages.${system} = rec {
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
      }
    );
}
