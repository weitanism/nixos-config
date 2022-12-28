{ pkgs, lib, config, ... }:

let
  wolfram-desktop = pkgs.callPackage ../../pkgs/wolfram-desktop.nix { };
  miwork = pkgs.callPackage ../../pkgs/miwork.nix { };
in
{
  options.custom-packages = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable custom packages.
      '';
    };
  };

  config = lib.mkIf config.custom-packages.enable {
    home.packages = [
      miwork
    ];
  };
}
