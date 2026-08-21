{
  flake.modules.nixos.prowlarr = {
    services = {
      prowlarr = {
        enable = true;
      };
    };
  };
}
