# pdfcraft-flake

Nix Flake for [PdfCraft](https://github.com/storytold/pdfcraft) (v0.6.0) — a fast, lightweight PDF editor and CLI toolkit.

Bundles both the desktop application (`pdfcraft`) and the headless CLI (`pdfcraft-cli`) with all desktop integration files (icons, mime types, `.desktop`) and OCR models included.

## Quick Run (No Installation)

Run the desktop application:
```bash
nix run github:<your-username>/pdfcraft-flake
```

Run the CLI tool:
```bash
nix run github:<your-username>/pdfcraft-flake#pdfcraft-cli -- --help
```

## Install in User Profile

```bash
nix profile install github:<your-username>/pdfcraft-flake
```

## NixOS Configuration

Add to your system's `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pdfcraft.url = "github:<your-username>/pdfcraft-flake";
  };

  outputs = { self, nixpkgs, pdfcraft, ... }@inputs: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # or aarch64-linux
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            pdfcraft.packages.${pkgs.system}.default
          ];
        })
        ./configuration.nix
      ];
    };
  };
}
```

## Home Manager

```nix
{
  inputs = {
    pdfcraft.url = "github:<your-username>/pdfcraft-flake";
  };

  # in home.nix:
  home.packages = [
    inputs.pdfcraft.packages.${pkgs.system}.default
  ];
}
```

## Supported Architectures

- `x86_64-linux`
- `aarch64-linux`
