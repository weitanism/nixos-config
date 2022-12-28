{ pkgs, config, lib, ... }:

{
  options.services.clash = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to enable clash.
      '';
    };
  };

  config = lib.mkIf config.services.clash.enable {
    systemd.user.services.clash = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Start clash client.";
      serviceConfig = {
        # Use default configuration file `~/.config/clash/config.yaml`
        ExecStart = ''${pkgs.clash}/bin/clash'';
      };
    };
  };
}
