# https://nix-community.github.io/home-manager/index.html#ch-nix-flakes
{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    hyprpicker.url = "github:hyprwm/hyprpicker";
    hyprpicker.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ nixpkgs
    , nixos-hardware
    , home-manager
    , emacs
    , hyprland
    , hyprpicker
    , ...
    }:
    let
      mergeAttrs = builtins.foldl' (a: b: a // b) { };

      overlays = [
        hyprpicker.overlays.default

        emacs.overlays.emacs

        (import ./overlay)
      ];

      mkSystem = attrs: (import ./lib/mk-system.nix) (attrs // {
        inherit nixpkgs nixos-hardware overlays home-manager hyprland;
      });
    in
    {
      nixosConfigurations = mergeAttrs [
        (mkSystem {
          hostname = "x1nano";
          username = "weitan";
          system = "x86_64-linux";
        })

        (mkSystem {
          hostname = "framework";
          username = "weitan";
          system = "x86_64-linux";
        })

        (mkSystem {
          hostname = "vm";
          username = "weitan";
          system = "x86_64-linux";
        })

        (mkSystem {
          hostname = "xps13";
          username = "weitan";
          system = "x86_64-linux";
        })
      ];

      images = {
        do = import ./server/image/do.nix { inherit nixpkgs; };
      };

      nixopsConfigurations.default = import ./server/do.nix { inherit nixpkgs; };

      devShells."x86_64-linux".default =
        let pkgs = import nixpkgs { system = "x86_64-linux"; };
        in
        pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            nixopsUnstable
          ];
        };
    };
}
