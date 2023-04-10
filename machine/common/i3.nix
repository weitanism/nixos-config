{ config, pkgs, callPackage, ... }:

{
  hardware.pulseaudio.enable = true;

  services.xserver = {
    enable = true;

    desktopManager.xterm.enable = false;

    displayManager = {
      defaultSession = "none+i3";
      gdm.enable = true;
      gdm.autoSuspend = false;
    };

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };

    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
      touchpad.disableWhileTyping = true;
    };

    xkbOptions = "ctrl:nocaps";
  };

  environment.systemPackages = with pkgs; [
    acpi
    killall
    i3-easyfocus
    i3lock-color
  ];
}
