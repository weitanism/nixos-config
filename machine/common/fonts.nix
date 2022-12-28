{ pkgs, ... }:

{
  fonts = {
    enableDefaultFonts = true;
    fontconfig = {
      enable = true;
      hinting = {
        enable = true;
        autohint = false;
      };
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "VictorMono Nerd Font" "Source Han Mono SC" ];
        sansSerif = [ "Source Han Sans SC" ];
        serif = [ "Source Han Serif SC" "Symbola" ];
      };
    };

    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      source-han-sans
      source-han-mono
      source-han-serif
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      wqy_microhei
      wqy_zenhei
      symbola
      jetbrains-mono
      victor-mono
      font-awesome
      material-icons
      material-design-icons
      nerdfonts
      iosevka
      weather-icons
    ];
  };
}
