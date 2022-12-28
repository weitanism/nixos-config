{ pkgs, ... }:

{
  # home.packages = [
  #   pkgs.catppuccin-gtk
  # ];

  home.pointerCursor = {
    name = "Catppuccin-Frappe-Dark";
    package = pkgs.catppuccin-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Dark";
      package = pkgs.catppuccin-gtk;
    };
    cursorTheme = {
      name = "Catppuccin-Frappe-Dark";
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    font = {
      name = "VictorMono Nerd Font";
      size = 14;
    };
    gtk3.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
    };
    gtk2.extraConfig = ''
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle="hintslight"
      gtk-xft-rgba="rgb"
    '';
  };
}
