{ osConfig, ... }:

let
  isWayland = osConfig.programs.hyprland.enable;
in
{
  services.dunst = {
    enable = !isWayland;
    settings = {
      global = {
        width = 500;
        height = 400;
        background = "#282A2E";
        foreground = "#C5C8C6";
        frame_color = "#8ABEB7";
        font = "VictorMono Nerd Font 16";
        transparency = 15;
        corner_radius = 12;
      };
    };
  };

  services.mako = {
    enable = isWayland;
    defaultTimeout = 5000;
    font = "Iosevka Nerd Font 14";
    width = 400;
    height = 300;
    backgroundColor = "#1E1D2FD0"; # "#1E1D2F" with around 0.7 opacity
    borderColor = "#96CDFB";
    borderRadius = 10;
    borderSize = 0;
    progressColor = "over #302D41";
    textColor = "#D9E0EE";
    extraConfig = ''
      [urgency=high]
      border-color=#F8BD96
    '';
  };
}
