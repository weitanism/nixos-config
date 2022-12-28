{
  time.timeZone = "Asia/Shanghai";

  systemd.services.systemd-networkd-wait-online.enable = false;

  users.mutableUsers = false;
}
