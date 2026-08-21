{
  flake.modules.nixos.podman = {
    virtualisation = {
      podman = {
        enable = true;
        autoPrune = {
          enable = true;
          dates = "daily";
          flags = [ "--all" ];
        };
      };

      oci-containers = {
        backend = "podman";
      };
    };
  };
}
