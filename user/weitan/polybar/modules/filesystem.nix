{ colors, ... }:

{
  "module/filesystem" = {
    type = "internal/fs";
    interval = 25;

    mount-0 = "/";

    label-mounted = "%{F${colors.primary}}%mountpoint%%{F-} %percentage_used%%";

    label-unmounted = "%mountpoint% not mounted";
    label-unmounted-foreground = "${colors.disabled}";
  };
}
