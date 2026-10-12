{
  description = "PdfCraft - Fast, lightweight PDF editor and CLI toolkit";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };

        runtimeLibs = with pkgs; [
          libGL
          libxkbcommon
          wayland
          vulkan-loader
          fontconfig
          xorg.libX11
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr
        ];

        sources = {
          x86_64-linux = {
            url = "https://github.com/storytold/pdfcraft/releases/download/v0.6.0/pdfcraft-0.6.0-linux-x86_64.tar.gz";
            hash = "sha256-mhNqcT4rXJsfCE1UFMfaWnFvKciU9JTXyPGzraS9ClM=";
          };
          aarch64-linux = {
            url = "https://github.com/storytold/pdfcraft/releases/download/v0.6.0/pdfcraft-0.6.0-linux-aarch64.tar.gz";
            hash = "sha256-IPtRVdtc7J9f4t053+x/Wb7S30TycK/vmWl2i6M4ilk=";
          };
        };

        srcInfo = sources.${system} or (throw "Unsupported architecture: ${system}");

        pdfcraft = pkgs.stdenv.mkDerivation {
          pname = "pdfcraft";
          version = "0.6.0";

          src = pkgs.fetchurl {
            inherit (srcInfo) url hash;
          };

          nativeBuildInputs = [
            pkgs.autoPatchelfHook
            pkgs.makeWrapper
          ];

          buildInputs = [
            pkgs.stdenv.cc.cc.lib
          ] ++ runtimeLibs;

          dontStrip = true;

          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp -r bin share $out/
            runHook postInstall
          '';

          postFixup = ''
            wrapProgram $out/bin/pdfcraft \
              --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath runtimeLibs}
          '';

          meta = with pkgs.lib; {
            description = "PdfCraft desktop app - lightweight PDF editor";
            homepage = "https://github.com/storytold/pdfcraft";
            license = with licenses; [ mit asl20 ];
            platforms = [ "x86_64-linux" "aarch64-linux" ];
            mainProgram = "pdfcraft";
          };
        };
      in
      {
        packages = {
          default = pdfcraft;
          pdfcraft = pdfcraft;
        };

        apps = {
          default = flake-utils.lib.mkApp {
            drv = pdfcraft;
          };
          pdfcraft = flake-utils.lib.mkApp {
            drv = pdfcraft;
          };
          pdfcraft-cli = flake-utils.lib.mkApp {
            drv = pdfcraft;
            name = "pdfcraft-cli";
          };
        };
      }
    );
}
