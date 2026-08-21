{ inputs, ... }: {
  flake.modules.nixos.bazarr = {
    imports = [ inputs.self.modules.nixos.media-group ];
    services = {
      bazarr = {
        enable = true;
        group = "media";
      };
    };

    systemd.services.bazarr.serviceConfig.UMask = "0002";
  };
}
