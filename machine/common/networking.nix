{ pkgs, hostname, username, ... }:

{
  imports = [
    ./proxy.nix
  ];

  networking.hostName = hostname;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.networkmanager.enable = true;
  # Pluggable interface.
  # networking.interfaces.enp0s13f0u2u1.useDHCP = true;
  networking.enableIPv6 = false;
  networking.resolvconf = {
    extraConfig = ''
      append_nameservers="127.0.1.1"
    '';
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://127.0.0.1:1082";
  # networking.proxy.noProxy = "127.0.0.1,localhost";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    # Python webserver share.
    8000
    # Simview.
    8888
    8889
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Disabling the `NetworkManager-wait-online` services makes boot
  # process faster.
  systemd.services.NetworkManager-wait-online.enable = false;
}
