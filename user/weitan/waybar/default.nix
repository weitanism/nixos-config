{ pkgs, enable }:

{
  inherit enable;
  package = pkgs.waybar.overrideAttrs (oldAttrs: {
    mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
  });
  style = ./style.css;
  settings = [{
    "layer" = "top";
    "position" = "top";
    modules-left = [
      "custom/launcher"
      "wlr/workspaces"
      "idle_inhibitor"
    ];
    modules-center = [
      "clock"
    ];
    modules-right = [
      "pulseaudio"
      "backlight"
      "temperature"
      "cpu"
      "memory"
      "network"
      "battery"
      "custom/dismiss-notifications"
      "custom/powermenu"
      "tray"
    ];
    "custom/launcher" = {
      "format" = " ";
      "on-click" = "~/.config/rofi/launcher.sh";
      "tooltip" = false;
    };
    "wlr/workspaces" = {
      "format" = "{icon}";
      "on-click" = "activate";
      # "on-scroll-up" = "hyprctl dispatch workspace e+1";
      # "on-scroll-down" = "hyprctl dispatch workspace e-1";
    };
    "idle_inhibitor" = {
      "format" = "{icon}";
      "format-icons" = {
        "activated" = "";
        "deactivated" = "";
      };
      "tooltip" = false;
    };
    "backlight" = {
      "device" = "intel_backlight";
      # "on-scroll-up" = "light -A 5";
      # "on-scroll-down" = "light -U 5";
      "format" = "{icon} {percent}%";
      "format-icons" = [ "" "" "" "" ];
    };
    "pulseaudio" = {
      "scroll-step" = 1;
      "format" = "{icon} {volume}%";
      "format-muted" = "婢 Muted";
      "format-icons" = {
        "default" = [ "" "" "" ];
      };
      "states" = {
        "warning" = 85;
      };
      "on-click" = "pamixer -t";
      "on-click-right" = "rofi-pactl";
      "tooltip" = false;
    };
    "battery" = {
      "interval" = 10;
      "states" = {
        "warning" = 20;
        "critical" = 10;
      };
      "format" = "{icon} {capacity}%";
      "format-icons" = [ "" "" "" "" "" "" "" "" "" ];
      "format-full" = "{icon} {capacity}%";
      "format-charging" = " {capacity}%";
      "tooltip" = false;
    };
    "clock" = {
      "interval" = 1;
      "format" = "{:%H:%M  %A %b %d}";
      "tooltip" = true;
      "timezone" = "Asia/Shanghai";
      "tooltip-format" = "<tt>{calendar}</tt>";
      "today-format" = "<span color='#ff6699'><b><u>{}</u></b></span>";
      "calendar-weeks-pos" = "right";
      "format-calendar-weeks" = "<span color='#99ffdd'><b>W{:%V}</b></span>";
      "format-calendar-weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
    };
    "memory" = {
      "interval" = 1;
      "format" = "﬙ {percentage}%";
      "states" = {
        "warning" = 85;
      };
    };
    "cpu" = {
      "interval" = 1;
      "format" = " {usage}%";
    };
    "mpd" = {
      "max-length" = 25;
      "format" = "<span foreground='#bb9af7'></span> {title}";
      "format-paused" = " {title}";
      "format-stopped" = "<span foreground='#bb9af7'></span>";
      "format-disconnected" = "";
      "on-click" = "mpc --quiet toggle";
      "on-click-right" = "mpc ls | mpc add";
      "on-click-middle" = "kitty --class='ncmpcpp' --hold sh -c 'ncmpcpp'";
      "on-scroll-up" = "mpc --quiet prev";
      "on-scroll-down" = "mpc --quiet next";
      "smooth-scrolling-threshold" = 5;
      "tooltip-format" = "{title} - {artist} ({elapsedTime:%M:%S}/{totalTime:%H:%M:%S})";
    };
    "network" = {
      "interval" = 1;
      "format-wifi" = "  {essid}({signalStrength}%)";
      "format-ethernet" = "  {ifname} ({ipaddr})";
      "format-disconnected" = "  Disconnected";
      "tooltip" = false;
      "on-click" = "wifi-switcher";
    };
    "temperature" = {
      # "hwmon-path"= "${env:HWMON_PATH}";
      #"critical-threshold"= 80;
      "tooltip" = false;
      "format" = " {temperatureC}°C";
    };
    "custom/dismiss-notifications" = {
      "format" = "<span color='#D9E0EE'></span>";
      "on-click" = "makoctl dismiss --all";
      "tooltip" = false;
    };
    "custom/powermenu" = {
      "format" = "<span color='#D9E0EE'></span>";
      "on-click" = "power-menu";
      "tooltip" = false;
    };
    "tray" = {
      "icon-size" = 15;
      "spacing" = 5;
    };
  }];
}
