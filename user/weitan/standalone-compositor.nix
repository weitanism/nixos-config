{ pkgs, osConfig, ... }:

let
  isWayland = osConfig.programs.hyprland.enable;
in
{
  services.picom = {
    enable = !isWayland;
  };
}
