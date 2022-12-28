{ colors, ... }:

{
  "module/xworkspaces" = {
    type = "internal/xworkspaces";

    label-active = "%name%";
    label-active-background = "${colors.background-alt}";
    label-active-underline = "${colors.primary}";
    label-active-padding = 1;

    label-occupied = "%name%";
    label-occupied-padding = 1;

    label-urgent = "%name%";
    label-urgent-background = "${colors.alert}";
    label-urgent-padding = 1;

    label-empty = "%name%";
    label-empty-foreground = "${colors.disabled}";
    label-empty-padding = 1;
  };
}
