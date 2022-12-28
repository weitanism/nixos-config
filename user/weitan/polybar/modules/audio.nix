{ colors, ... }:

{
  "module/pulseaudio" = {
    type = "internal/pulseaudio";

    format-volume-prefix = "墳 ";
    format-volume-prefix-font = 2;
    format-volume-prefix-foreground = "${colors.primary}";
    format-volume = "<label-volume>";

    label-volume = "%percentage%%";

    label-muted = "婢";
    label-muted-font = 2;
    label-muted-foreground = "${colors.disabled}";
  };
}
