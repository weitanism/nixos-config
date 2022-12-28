{ pkgs, colors, ... }:

let
  mkScript = import ../../../../lib/mk-script.nix pkgs;
  colorize = color: text: "%{F${color}}${text}%{F-}";
  importModule = file: (import file { inherit pkgs colors colorize mkScript; });

  mergeAttrs = builtins.foldl' (a: b: a // b) { };
in
mergeAttrs (
  builtins.map importModule [
    ./workspace.nix
    ./window.nix
    ./filesystem.nix
    ./audio.nix
    ./cpu.nix
    ./memory.nix
    ./network.nix
    ./date.nix
    ./battery.nix
    ./backlight.nix
    ./weather.nix
  ]
)
