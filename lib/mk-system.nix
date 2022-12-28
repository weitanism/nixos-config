{ hostname
, username
, system
, nixpkgs
, nixos-hardware
, home-manager
, hyprland
, overlays
}:

let
  injected-args = {
    hostname = hostname;
    username = username;
  };
in
{
  ${hostname} = nixpkgs.lib.nixosSystem {
    inherit system;

    modules = [
      {
        nixpkgs.overlays = overlays ++ (import ../machine/${hostname}/overlays.nix);
        nixpkgs.config.allowUnfree = true;
      }

      ../machine/${hostname}/configuration.nix
      ../machine/${hostname}/extra-configuration.nix
      ../user/${username}/nixos.nix

      ../machine/common

      hyprland.nixosModules.default

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${username} = {
          imports = [ ../user/${username}/home.nix ];
          config._module.args = injected-args;
        };
      }

      # We expose some extra arguments so that our modules can parameterize
      # better based on these values.
      { config._module.args = injected-args; }
    ] ++ (import ../machine/${hostname}/extra-nixos-modules.nix {
      inherit hostname username system nixpkgs nixos-hardware home-manager;
    });
  };
}
