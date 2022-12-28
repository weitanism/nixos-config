{ pkgs, ... }:

{
  qt = {
    enable = true;
    platformTheme = "gnome"; # "gtk2";
    style = "adwaita-dark"; # "gtk2";
  };

  environment.variables = {
    QT_QPA_PLATFORM_PLUGIN_PATH =
      "${pkgs.qt5.qtbase.bin.outPath}/lib/qt-${pkgs.qt5.qtbase.version}/plugins";
  };
}
