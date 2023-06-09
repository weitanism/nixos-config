{ config, pkgs, ... }:

let
  link = file: config.lib.file.mkOutOfStoreSymlink "/etc/nixos/user/weitan/emacs/${file}";
in
{
  imports = [
    ./non-melpa-packages.nix
  ];

  home.file.".emacs.d/init.el".source = link "init.el";
  home.file.".emacs.d/lisp".source = link "lisp";
}
