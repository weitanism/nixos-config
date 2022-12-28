{ colors, ... }:

{
  "module/memory" = {
    type = "internal/memory";
    interval = 2;
    format-prefix = " ";
    format-prefix-font = 2;
    format-prefix-foreground = "${colors.primary}";
    label = "%percentage_used:2%%";
  };
}
