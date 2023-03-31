{ config, pkgs, ... }:

let
  multi-translate =
    let repo = pkgs.fetchFromGitHub {
      repo = "multi-translate.el";
      owner = "twlz0ne";
      rev = "369589b39bb7f1ec58fddbeb0914f231d94ae0fb";
      sha256 = "sha256-Z7we7OahEDK2QuEMSPuNYzNKsW3XQHPIPaM6xws5/n8=";
    };
    in "${repo}/multi-translate.el";
in
{
  home.file.".emacs.d/non-melpa/multi-translate.el".source = multi-translate;
}
