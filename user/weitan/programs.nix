{ pkgs, lib, osConfig, ... }:

{
  programs = {
    fish.enable = true;
    fish.interactiveShellInit = lib.mkAfter ''
      set --global pure_symbol_prompt '~>'

      thefuck --alias f | source

      any-nix-shell fish --info-right | source
    '';
    fish.shellAbbrs = {
      g = "git";
      p = "all_proxy=http://127.0.0.1:1080";
      magit = "emacsclient -nc --eval \"(show-magit-only)\"";
    };
    fish.plugins = [
      { name = "done"; src = pkgs.fishPlugins.done.src; }
      { name = "pure"; src = pkgs.fishPlugins.pure.src; }
    ];

    man.generateCaches = true;

    autojump.enable = true;

    git = {
      enable = true;
      lfs.enable = true;

      userName = "weitanism";
      userEmail = "weitanism@pm.me";

      aliases = {
        co = "checkout";
        st = "status";
        cp = "cherry-pick";
        tree = "log --oneline --graph --all";
        df = "difftool";
      };

      ignores = [ ];

      extraConfig = {
        diff.tool = "difftastic";
        difftool."difftastic".cmd = ''difft "$LOCAL" "$REMOTE"'';
        difftool.prompt = false;
        pager.difftool = true;
      };
    };

    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      # optional for nix flakes support in home-manager 21.11, not required in
      # home-manager unstable or 22.05
      # nix-direnv.enableFlakes = true;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "fd --type file --follow"; # FZF_DEFAULT_COMMAND
      defaultOptions = [ "--height 20%" ]; # FZF_DEFAULT_OPTS
      fileWidgetCommand = "fd --type file --follow"; # FZF_CTRL_T_COMMAND
    };

    ssh = {
      enable = true;
      controlMaster = "auto";
      controlPersist = "30m";
    };

    waybar = (import ./waybar) {
      inherit pkgs;
      enable = osConfig.programs.hyprland.enable;
    };
  };
}
