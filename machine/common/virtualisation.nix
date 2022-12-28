{ username, ... }:

{
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.oci-containers.backend = "podman";

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ username ];
}
