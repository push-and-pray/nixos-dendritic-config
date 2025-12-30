{
  flake.modules.nixos.docker = {
    virtualisation.docker.enable = true;
  };

  flake.lib.dockerAccess = username: {
    users.users.${username}.extraGroups = ["docker"];
  };
}
