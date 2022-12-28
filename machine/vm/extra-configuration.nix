{ pkgs, ... }:

{
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.pop-shell
  ];

  systemd.services.nix-daemon.environment = {
    http_proxy = "http://192.168.50.176:1083";
    https_proxy = "http://192.168.50.176:1083";
  };

  virtualisation.vmware.guest.enable = true;
}
