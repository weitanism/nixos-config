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
    activeOpacity = 0.9;
    opacityRules = [
      # Set opacity of hidden windows to 0. This rule should be put on
      # the first place as picom only use the first matching rule.
      # See https://github.com/yshui/picom/issues/317 and
      # https://www.reddit.com/r/i3wm/comments/mehr01/weirdness_with_tabbed_transparent_windows_picom/
      "0:_NET_WM_STATE@:32a = '_NET_WM_STATE_HIDDEN'"

      "100:class_g = 'Rofi'"
      "100:class_g = 'Chromium-browser'"
      "100:class_g = 'Bytedance-feishu'"
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
