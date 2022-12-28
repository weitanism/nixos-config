{ colors, colorize, ... }:

let
  downspeedText = colorize colors.secondary "%downspeed%";
  buildNetworkModule = { interface-type, text, icon }: {
    inherit interface-type;

    type = "internal/network";
    interval = 5;

    label-connected = "${text} ${downspeedText}";
    format-connected-prefix = "${icon} ";
    format-connected-prefix-foreground = "${colors.primary}";
    format-connected-prefix-font = 2;

    label-disconnected = "${icon}";
    label-disconnected-font = 2;
  };
in
{
  "module/wlan" = buildNetworkModule {
    interface-type = "wireless";
    icon = " ";
    text = "%essid%";
  };

  "module/eth" = {
    interface-type = "wired";
    icon = " ";
    text = "%local_ip%";
  };
}
