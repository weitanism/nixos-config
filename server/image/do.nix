{ nixpkgs }:

let
  pkgs = import nixpkgs { system = "x86_64-linux"; };
  config = {
    imports = [
      "${nixpkgs}/nixos/modules/virtualisation/digital-ocean-image.nix"
      ./auth.nix
    ];

    virtualisation.digitalOceanImage.compressionMethod = "bzip2";

    system.stateVersion = "22.05";

    networking.hostName = "nixos";
  };
in
(pkgs.nixos config).digitalOceanImage
