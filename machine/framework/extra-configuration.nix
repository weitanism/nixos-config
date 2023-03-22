{ pkgs, username, ... }:

{
  imports = [
    ../common/i3.nix
  ];

  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelParams = [
    # Fix the random freezing issue(dmesg says "[drm] GPU HANG: ecode
    # 12:0:00000000"). See
    # https://community.frame.work/t/tracking-hard-freezing-on-fedora-36-with-the-new-12th-gen-system/20675/146
    "i915.enable_psr=0"
  ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # systemd.services.nix-daemon.environment = {
  #   http_proxy = "http://127.0.0.1:1080";
  #   https_proxy = "http://127.0.0.1:1080";
  # };
}
