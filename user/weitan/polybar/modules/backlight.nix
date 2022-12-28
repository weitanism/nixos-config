{ colors, ... }:

{
  "module/backlight" =
    {
      type = "internal/backlight";

      card = "intel_backlight";

      format-prefix = "ﯦ  ";
      format-prefix-font = 2;
      format-prefix-foreground = "${colors.primary}";
    };
}
