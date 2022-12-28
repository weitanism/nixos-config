{ pkgs, ... }:

with pkgs;
let
  alacritty-colorscheme = fetchFromGitHub {
    repo = "alacritty-theme";
    owner = "eendroroy";
    rev = "b7bde1e905c26857e95adfd129a4fd1b8718482e";
    sha256 = "MHl8EmI+K8c0xpS/CdQI4EatM07glfF94P45X+gAhZo=";
  };

  common-config = pkgs.writeText "common.yml" ''
    font:
      size: 11

    selection:
      semantic_escape_chars: ",│`|:\"' ()[]{}<>\t="
      save_to_clipboard: true

    shell:
      program: fish
  '';

  set-alacritty-theme = writeShellScriptBin "set-alacritty-theme" ''
    cd ~/.config/alacritty || exit

    theme=$1
    ln -sf "$theme.yml" alacritty.yml
  '';
in
{
  home.packages = [
    alacritty
    set-alacritty-theme
  ];

  home.file.".config/alacritty/dark.yml".text = ''
    import:
      - ${alacritty-colorscheme}/themes/gruvbox_dark.yaml
      - ${common-config}
  '';
  home.file.".config/alacritty/light.yml".text = ''
    import:
      - ${alacritty-colorscheme}/themes/gruvbox_light.yaml
      - ${common-config}
  '';

  home.activation = {
    setup-alacritty-theme = ''
      if [[ ! -f ~/.config/alacritty/alacritty.yml ]]; then
        set-alacritty-theme dark
      fi
    '';
  };
}
