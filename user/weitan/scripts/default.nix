{ pkgs, osConfig, ... }:

let
  isWayland = osConfig.programs.hyprland.enable;
  lockscreenWayland = pkgs.writeShellScriptBin "lockscreen" ''
    swaylock  \
        --screenshots \
        --clock \
        --indicator \
        --indicator-radius 100 \
        --indicator-thickness 7 \
        --effect-blur 7x5 \
        --effect-vignette 0.5:0.5 \
        --ring-color 3b4252 \
        --key-hl-color 880033 \
        --line-color 00000000 \
        --inside-color 00000088 \
        --separator-color 00000000 \
        --grace 2 \
        --grace-no-mouse \
        --grace-no-touch \
        --fade-in 0.3 \
        --daemonize
  '';
  lockscreenXorg = pkgs.writeShellScriptBin "lockscreen" ''
    i3lock-color \
        --blur 5 \
        --bar-indicator \
        --bar-pos y+h \
        --bar-direction 1 \
        --bar-max-height 20 \
        --bar-base-width 20 \
        --bar-color 000000cc \
        --keyhl-color 880088cc \
        --bar-periodic-step 50 \
        --bar-step 50 \
        --redraw-thread \
        \
        --clock \
        --force-clock \
        --time-pos x+5:y+h-40 \
        --time-color 880088ff \
        --date-pos tx:ty+15 \
        --date-color 990099ff \
        --date-align 1 \
        --time-align 1 \
        --ringver-color 8800ff88 \
        --ringwrong-color ff008888 \
        --status-pos x+5:y+h-16 \
        --verif-align 1 \
        --wrong-align 1 \
        --verif-color ffffffff \
        --wrong-color ffffffff \
        --modif-pos -50:-50
  '';
  lockscreen = if isWayland then lockscreenWayland else lockscreenXorg;

  power-menu = pkgs.writeShellScriptBin "power-menu" ./rofi-power-menu;

  switcher = pkgs.writeShellScriptBin "switcher" ''
    rofi -combi-modi window:${./rofi-hyprland-switcher},drun -show combi -modi combi -sorting-method fzf -sort -matching fuzzy
  '';

  wifi-switcher = pkgs.writeShellScriptBin "wifi-switcher" ./rofi-nmcli;

  set-system-theme = pkgs.writeShellScriptBin "set-system-theme" ''
    EMACS=''${EMACS:-"yes"}
    theme=$1 # available themes: light, dark

    set-alacritty-theme "$theme"

    if [[ $EMACS = "yes" ]]; then
      emacsclient --eval "($theme-theme)"
    fi
  '';

  mkRofiApp = name: app:
    let script = pkgs.writeText name ''
      ${builtins.readFile ./rofi.py}
      ${builtins.readFile app}
    '';
    in
    pkgs.writeShellApplication
      {
        inherit name;
        runtimeInputs = [ pkgs.python3 script ];
        text = ''
          python3 ${script}
        '';
      };

  rofi-pactl = mkRofiApp "rofi-pactl" ./rofi-pactl.py;

  rg-replace = pkgs.writeShellScriptBin "rg-replace" ./rg-replace.sh;

  install-rime-settings = pkgs.writeShellScriptBin "install-rime-settings" ''
    set -e
    set -x

    if [[ ! -e ~/workspace/plum ]]; then
        mkdir -p ~/workspace
        cd ~/workspace
        git clone --depth 1 https://github.com/rime/plum.git
    fi

    RIM_DIR=~/.local/share/fcitx5/rime/

    pushd $RIM_DIR
    ls | grep -v '.custom.yaml' | xargs rm -rfv
    popd

    cd ~/workspace/plum
    rime_dir=$RIM_DIR bash rime-install iDvel/rime-ice:others/recipes/full
  '';
in
{
  home.packages = [
    lockscreen
    power-menu
    switcher
    wifi-switcher
    set-system-theme
    rofi-pactl
    rg-replace
    install-rime-settings
  ];
}
