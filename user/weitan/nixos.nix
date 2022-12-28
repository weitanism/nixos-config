{ pkgs, ... }:

{
  users.users.weitan = {
    isNormalUser = true;
    extraGroups =
      [ "wheel" "video" "audio" "sound" "input" "docker" "adbusers" "networkmanager" ];
    hashedPassword = "$6$r7jJJfXeeMaIded3$oEO5w0Gs/rOPXsDKB9UPcofyeJXD1oiHyfpu.0pt7u.D24JD3rHH2XNajUXTlg29EaO5iLEWGpSSEG7s3u3iC0";
  };

  programs.light.enable = true;

  programs.adb.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    package = pkgs._1password-gui-beta;
    polkitPolicyOwners = [ "weitan" ];
  };

  programs.kdeconnect.enable = true;

  time.timeZone = "Asia/Shanghai";
}
