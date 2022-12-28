{ colors, ... }:

{
  "module/date" = {
    type = "internal/date";
    interval = 1;

    date = "%b %d, %Y %H:%M:%S";
    # date-alt = "%H:%M";

    label = "%date%";
    label-foreground = "${colors.primary}";
  };
}
