{ pkgs, username, ... }:

{
  imports = [
    ../common/i3.nix
  ];

  boot.supportedFilesystems = [ "ntfs" ];

  systemd.services.battery_check = {
    description = "Send notification if battery is low";
    serviceConfig = {
      Type = "oneshot";
      User = username;
      ExecStart = pkgs.writeScript "battery_check" ''
        #!${pkgs.bash}/bin/bash --login
        . <(udevadm info -q property -p /sys/class/power_supply/BAT0 |
            grep -E 'POWER_SUPPLY_(CAPACITY|STATUS)=')
        if [[ $POWER_SUPPLY_STATUS = Discharging && $POWER_SUPPLY_CAPACITY -lt 15 ]]; then
          notify-send -u critical "🪫 Battery is low: $POWER_SUPPLY_CAPACITY";
        fi
      '';
    };
    environment = {
      DISPLAY = ":0";
      DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
      PRE_COMMIT_COLOR = "always";
    };
    after = [ "display-manager.service" ];
    startAt = "*:0/5";
  };

  services.xserver.wacom.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  systemd.services.nix-daemon.environment = {
    http_proxy = "http://127.0.0.1:1080";
    https_proxy = "http://127.0.0.1:1080";
  };
}
