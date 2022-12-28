{
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    #permitRootLogin = "yes";
  };

  users.mutableUsers = false;
  users.users.weitan = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$OrI7mqbCbNJAEEAv$u/8Pxh94gaPb8yAtt4hiLb1fkEXtDH1HGUU./ZuOZSSPGSnSKUZXQXoZaRQsilAflu5rUU4anC4xDLg5kq34r1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJvKRF55h+z9AL4SIl3THgAf6QvEKvSwNUYHEP09h6MJ weitan"
    ];
  };
}
