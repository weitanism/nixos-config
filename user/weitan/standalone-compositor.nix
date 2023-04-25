{ pkgs, osConfig, ... }:

let
  isWayland = osConfig.programs.hyprland.enable;
in
{
  services.picom = {
    enable = !isWayland;
    backend = "glx";
    fade = true;
    fadeDelta = 5;
    inactiveOpacity = 0.8;
    opacityRules = [
      "100:class_g = 'Rofi'"
    ];
    settings = {
      corner-radius = 12.0;
      blur = {
        method = "dual_kawase";
        strength = 5;
        background = true;
        background-frame = true;
        background-fixed = true;
      };
      blur-background-exclude = [
        "role = 'xborder'"
      ];
    };
  };
}
