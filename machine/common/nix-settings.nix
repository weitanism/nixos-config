{
  nix.settings.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
  nix.settings.trusted-substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];

  # Protect nix-shell against garbage collection.
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
