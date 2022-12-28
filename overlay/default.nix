final: prev:

{
  emacs = prev.callPackage ../pkgs/emacs.nix { };
  catppuccin-cursors = prev.callPackage ../pkgs/catppuccin-cursors.nix { };
  wpa_supplicant = prev.callPackage ../pkgs/wpa-supplicant.nix { inherit (prev) system; };
  tree-sitter-grammars = (import ./tree-sitter-grammars.nix) final prev;
}
