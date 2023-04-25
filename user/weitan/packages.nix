{ pkgs, hostname, osConfig, ... }:

with pkgs;
let
  isWayland = osConfig.programs.hyprland.enable;
  rofi =
    if isWayland
    then pkgs.rofi-wayland else pkgs.rofi;
  rofiWithPlugins = rofi.override {
    plugins = [
      rofi-calc
      rofi-emoji
      rofi-systemd
      rofi-file-browser
    ];
  };
  # Enable c-ares support to use `--dns-servers` option.
  curlWithCAres = curl.override { c-aresSupport = true; };
  my-python = python310.withPackages (python-packages:
    with python-packages;
    [
      # For Emacs lsp-bridge
      epc
      orjson
      six
    ]);
  waylandSpecificPackages = [
    swaylock-effects
    swayidle
    hyprpaper
    hyprpicker
    wayshot
    slurp
    swappy
    wl-clipboard
    wdisplays
  ];
  xorgSpecificPackages = [ ];
in
{
  imports = [
    ./custom-packages.nix
  ];

  custom-packages.enable = builtins.elem hostname [ "x1nano" "framework" ];

  home.packages =
    [
      git
      ncdu
      hardinfo
      mtr
      qjournalctl
      fsearch
      tdesktop
      chromium
      neofetch
      screenfetch
      pstree
      file
      tmux
      iftop
      vim
      rofiWithPlugins
      rofi-power-menu
      kitty
      dmenu
      nitrogen
      xmobar
      pamixer
      brightnessctl
      man
      fish
      dpkg
      patchelf
      binutils
      nixfmt
      nix-index
      cached-nix-shell
      helix
      pulseaudio
      copyq
      libnotify
      pciutils
      betterlockscreen
      light

      # Development tools.
      bazelisk
      ccls
      gdb
      zeal
      clang-tools
      bazel-buildtools
      nodejs
      yarn
      protobuf
      my-python
      pre-commit
      include-what-you-use
      cpplint
      pax-utils
      rustup
      nodePackages.prettier
      git-extras
      rnix-lsp
      nixpkgs-fmt
      nodePackages.bash-language-server
      shellcheck
      shfmt
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.typescript-language-server
      haskell-language-server
      ghc
      taplo
      gitui
      gitRepo
      git-crypt

      # Command line tools.
      fd
      ripgrep
      tree
      any-nix-shell
      unzip
      sysz
      sshfs
      difftastic
      graphviz
      jq
      xclip
      curlWithCAres
      # New tools from https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/
      exa
      duf
      du-dust
      tldr
      fx
      kubectl
      thefuck
      xdotool
      xorg.xwininfo
      wirelesstools

      # GUI tools.
      cider
      xarchiver
      simplescreenrecorder
      xournalpp
      feh
      arandr
      networkmanagerapplet
      dolphin

      # Docs.
      man-pages
      glibcInfo

      # Paper tools.
      texlive.combined.scheme-small

      # Emacs
      emacs
      emacs-all-the-icons-fonts
      pandoc
      universal-ctags
      ispell

      # Media tools.
      kdenlive
      pitivi
      lightworks

      # Blogging tools.
      hugo

      # Reading tools.
      okular
      crow-translate
    ] ++ (if isWayland then waylandSpecificPackages else xorgSpecificPackages);
}
