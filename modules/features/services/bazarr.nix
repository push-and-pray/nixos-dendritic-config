{ inputs, ... }: {
  flake.modules.nixos.bazarr = {
    imports = [ inputs.self.modules.nixos.media-group ];
    services = {
      bazarr = {
        enable = true;
        group = "media";
      };

      nginx.virtualHosts."bazarr.altanen.casa" = {
        useACMEHost = "altanen.casa";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:6767";
          proxyWebsockets = true;
        };
      };
    };

    systemd.services.bazarr.serviceConfig.UMask = "0002";
  };
}
