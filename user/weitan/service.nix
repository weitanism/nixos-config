{
  services.status-notifier-watcher.enable = true;

  services.emacs.enable = true;

  services.udiskie = {
    enable = true;
    tray = "always";
    settings = {
      program_options = {
        appindicator = true;
      };
    };
  };

  services.flameshot = {
    enable = true;

    settings = {
      General = {
        disabledTrayIcon = true;
        showStartupLaunchMessage = false;
      };
    };
  };
}
