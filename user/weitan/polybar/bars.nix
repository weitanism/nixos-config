{ colors }:

{
  "bar/default" = {
    width = "100%";
    height = "24pt";
    radius = "6";
    background = "${colors.background}";
    foreground = "${colors.foreground}";

    line-size = "3pt";

    border-size = "4pt";
    border-color = "#000000";

    padding-left = 0;
    padding-right = 1;

    module-margin = 1;

    separator = "|";
    separator-foreground = "${colors.disabled}";

    font-0 = "VictorMono Nerd Font:size=14;2";
    font-1 = "VictorMono Nerd Font:size=14;4";
    font-2 = "Weather Icons:size=12;4";

    modules-left = "xworkspaces xwindow";
    modules-right = "filesystem pulseaudio backlight cpu memory wlan eth weather date battery0 battery1";

    cursor-click = "pointer";
    cursor-scroll = "ns-resize";

    enable-ipc = true;

    tray-position = "right";

    # override-redirect = true;
    # wm-restack = "i3";
  };
}
