{ colors, ... }:

{
  "module/cpu" = {
    type = "internal/cpu";
    interval = 2;
    format-prefix = " ";
    format-prefix-font = 2;
    format-prefix-foreground = "${colors.primary}";
    label = "%percentage:2%%";
  };
}
