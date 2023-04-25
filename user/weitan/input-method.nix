{ config, pkgs, ... }:

with pkgs;
let
  fcitx5-dark-transparent = fetchFromGitHub {
    repo = "fcitx5-dark-transparent";
    owner = "hosxy";
    rev = "e196b8aa748d6a8747ff9f943a3ca25f45441c37";
    sha256 = "sha256-kj6QvcnFycZt5z5jZLDV6vfqAiM1HWAede9lXZYb+o0=";
  };
in
{
  i18n = {
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-rime
        fcitx5-configtool
        fcitx5-gtk
      ];
    };
  };

  # Config files.
  home.file.".config/fcitx5/conf/classicui.conf".text = ''
    Font="Source Han Sans SC 20"

    Vertical Candidate List=True

    PerScreenDPI=True

    Theme=fcitx5-dark-transparent
  '';
  # https://github.com/rime/home/wiki/CustomizationGuide
  home.file.".local/share/fcitx5/rime/default.custom.yaml".text = ''
    patch:
      key_binder/bindings/+:
      - { when: composing, accept: Tab, send: Shift+Left }
      - { when: composing, accept: Shift+Tab, send: Shift+Right }
  '';
  home.file.".local/share/fcitx5/themes/fcitx5-dark-transparent".source = fcitx5-dark-transparent;

  systemd.user.sessionVariables = config.home.sessionVariables;

  # NOTE: Run `install-rime-settings`(defined in
  # `user/weitan/scripts/default.nix`) to install default setting and
  # schemas.
}
