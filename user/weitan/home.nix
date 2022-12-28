{ config, lib, pkgs, ... }:

{
  imports = [
    ./service.nix
    ./programs.nix
    ./packages.nix
    ./config-files.nix
    ./alacritty
    ./scripts
    ./theme.nix
    ./input-method.nix
    ./notification-daemon.nix
    ./polybar
    ./standalone-compositor.nix
    ./emacs
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.stateVersion = "22.05";

  home.keyboard = {
    layout = "us";
    options = [ "ctrl:swapcaps" ];
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };

  xdg.desktopEntries = {
    myemacsclient = {
      name = "MyEmacsclient";
      genericName = "Text Editor";
      comment = "Edit text";
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "application/json"
        "text/x-c"
        "text/x-c++"
      ];
      exec = "emacsclient -nc --alternate-editor emacs %F";
      icon = "emacs";
      type = "Application";
      terminal = false;
      categories = [ "Development" "TextEditor" ];
    };
  };

  xdg.mimeApps.defaultApplications = {
    "inode/directory" = [ "org.kde.dolphin.desktop" ];
    "application/x-compressed-tar" = [ "xarchiver.desktop" ];
    "application/zip" = [ "xarchiver.desktop" ];
    "text/plain" = [ "myemacsclient.desktop" ];
  };
}

