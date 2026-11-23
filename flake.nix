
{
  description = "Beer - terminal beer physics simulator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    beer-src = {
      url = "github:ewasion137/beer/v1.0.0";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, beer-src }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "beer";
            version = "1.0.0";

            src = beer-src;

            nativeBuildInputs = [
              pkgs.gnumake
            ];

            dontConfigure = true;

            buildPhase = ''
              runHook preBuild
              make posix
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              install -Dm755 beer $out/bin/beer
              runHook postInstall
            '';

            meta = {
              description = "Terminal beer physics simulator";
              homepage = "https://github.com/ewasion137/beer";
              license = pkgs.lib.licenses.gpl3Only;
              platforms = systems;
              mainProgram = "beer";
            };
          };
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.gcc
              pkgs.gnumake
            ];
          };
        }
      );
    };
}
