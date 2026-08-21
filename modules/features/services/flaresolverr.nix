{
  flake.modules.nixos.prowlarr = {
    services = {
      flaresolverr = {
        enable = true;
      };
    };
  };
}
