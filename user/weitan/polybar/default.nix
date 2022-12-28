{ pkgs, osConfig, ... }:

let
  isWayland = osConfig.programs.hyprland.enable;

  colors = import ./colors.nix;
  bars = import ./bars.nix { inherit colors; };
  modules = import ./modules { inherit pkgs colors; };
in
{
  services.polybar = {
    enable = !isWayland;
    package = pkgs.polybarFull;
    script = "polybar default &";
    settings =
      {
        settings = {
          screenchange-reload = true;
          pseudo-transparency = true;
        };
      } // bars // modules;
  };
}

