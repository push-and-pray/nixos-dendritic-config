{
  flake.modules.nixos.media-group = {
    users.groups."media" = {
      gid = 888;
    };
  };
}
