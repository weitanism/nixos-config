{ config, pkgs, ... }:

let
  link = file: config.lib.file.mkOutOfStoreSymlink "/etc/nixos/user/weitan/${file}";
in
{
  home.file.".config/helix".source = link "helix";
  home.file.".config/hypr".source = link "hypr";
  home.file.".config/i3".source = link "i3";
  home.file.".config/i3status-rust/config.toml".source = link "i3/i3status-rust.toml";
  home.file.".config/rofi/config.rasi".source = link "rofi-config.rasi";

  home.file.".config/swappy/config".text = ''
    [Default]
    save_dir=$HOME/Pictures/ScreenShots
    save_filename_format=swappy-%Y%m%d-%H%M%S.png
    show_panel=true
    line_size=5
    text_size=20
    text_font=sans-serif
    paint_mode=arrow
    early_exit=true
    fill_shape=false
  '';

  home.file.".config/wallpaper.png".source = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src;
}
