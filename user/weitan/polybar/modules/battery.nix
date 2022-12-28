{ ... }:

let
  mkBatteryModule = battery:
    {
      type = "internal/battery";
      full-at = 99;
      low-at = 5;
      battery = battery;
      adapter = "AC";
      poll-interval = 5;

      format-charging = "<animation-charging> ";
      format-discharging = "<ramp-capacity> ";
      format-full = "<ramp-capacity> ";
      format-low = "<animation-low> ";
      format-charging-font = 2;
      format-discharging-font = 2;
      format-full-font = 2;
      format-low-font = 2;

      ramp-capacity-0 = "";
      ramp-capacity-1 = "";
      ramp-capacity-2 = "";
      ramp-capacity-3 = "";
      ramp-capacity-4 = "";

      animation-charging-0 = "";
      animation-charging-1 = "";
      animation-charging-2 = "";
      animation-charging-3 = "";
      animation-charging-4 = "";
      animation-charging-framerate = 750;

      animation-low-0 = "!";
      animation-low-1 = "";
      animation-low-framerate = 200;
    };
in
{
  "module/battery0" = mkBatteryModule "BAT0";
  "module/battery1" = mkBatteryModule "BAT1";
}
