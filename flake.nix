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
          libx11
          libxcursor
          libxi
          libxrandr
        ];

        sources = {
          x86_64-linux = {
            url = "https://github.com/storytold/pdfcraft/releases/download/v0.6.0/pdfcraft-0.6.0-linux-x86_64.tar.gz";
            hash = "sha256-mhNuceN7RZ7VdG2+GaNkzoTPXZlcb2yYr2FH2Bg5ClM=";
          };
          aarch64-linux = {
            url = "https://github.com/storytold/pdfcraft/releases/download/v0.6.0/pdfcraft-0.6.0-linux-aarch64.tar.gz";
            hash = "sha256-IPtRddtcmSNVtvHHPMWxY74F0vTycK/vahhLuuOzilk=";
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
              --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath runtimeLibs} \
              --suffix LD_LIBRARY_PATH : "/run/opengl-driver/lib:/run/opengl-driver-32/lib:/usr/lib64:/usr/lib/x86_64-linux-gnu:/usr/lib:/usr/lib/aarch64-linux-gnu"
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
