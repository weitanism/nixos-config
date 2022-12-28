{ pkgs, username, ... }:

{
  imports = [
    ../common/i3.nix
  ];

  boot.supportedFilesystems = [ "ntfs" ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # systemd.services.nix-daemon.environment = {
  #   http_proxy = "http://127.0.0.1:1080";
  #   https_proxy = "http://127.0.0.1:1080";
  # };
}
