{
  services.xserver = {
    enable = true;
    displayManager = {
      defaultSession = "hyprland";
      gdm.enable = true;
    };
  };

  programs.hyprland.enable = true;

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  # rtkit is optional but recommended
  security.rtkit.enable = true;
  # NOTE: Don't forget to enable chromium's pipewire support at
  # chrome://flags/#enable-webrtc-pipewire-capturer
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
