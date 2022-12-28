{ nixpkgs }:

{
  inherit nixpkgs;

  network.description = "Digital Ocean Machines";
  network.storage.legacy = {
    databasefile = "~/.nixops/deployments.nixops";
  };

  webserver = { config, pkgs, modulesPath, ... }: rec {
    deployment.targetHost = builtins.readFile ./webserver-ip.secret;

    imports = [
      (modulesPath + "/virtualisation/digital-ocean-config.nix")

      ./image/auth.nix
    ];

    networking.hostName = "webserver";
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    security.acme.acceptTerms = true;
    security.acme.defaults.email = "chrisyunhua@gmail.com";

    services.nginx = {
      enable = true;
      virtualHosts = {
        ${services.ntfy-sh.settings.base-url} = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1${services.ntfy-sh.settings.listen-http}";
            proxyWebsockets = true;
          };
        };

        "workflow.chrisyunhua.com" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${services.node-red.port}";
            proxyWebsockets = true;
          };
        };
      };
    };

    services.ntfy-sh = {
      enable = true;
      settings = {
        listen-http = ":8080";
        base-url = "notification.chrisyunhua.com";
        behind-proxy = true;
        auth-default-access = "deny-all";
        auth-file = "/var/ntfy/ntfy-user.db";
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/ntfy 0755 ntfy-sh users"
    ];

    services.fail2ban = {
      enable = true;
      maxretry = 3;
    };

    system.activationScripts = {
      # The ntfy not support declarative ACL yet, so we use the
      # activation script to add default user.
      setup-ntfy-users =
        let ntfy = "${pkgs.ntfy-sh}/bin/ntfy";
        in
        ''
          auth_file=${services.ntfy-sh.settings.auth-file}
          ${ntfy} user --auth-file=$auth_file list 2>&1 \
            | grep '^user' \
            | ${pkgs.gawk}/bin/gawk '{{print $2}}' \
            | grep -v '\*' \
            | ${pkgs.findutils}/bin/xargs -I{} ${ntfy} user --auth-file=$auth_file remove {}
          NTFY_PASSWORD=ntfypass ${ntfy} user --auth-file=$auth_file add --role=admin chris
        '';
    };

    service.node-red = {
      enable = true;
      port = 1880;
      configFile = ./node-red-setting.js;
    };
  };
}
