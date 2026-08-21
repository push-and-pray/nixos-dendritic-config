{
  flake.modules.nixos.jellyfin = {
    services = {
      seerr = {
        enable = true;
      };
    };
  };
}
