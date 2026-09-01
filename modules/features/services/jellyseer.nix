{
  flake.modules.nixos.jellyfin = {
    services = {
      seerr = {
        enable = true;
      };

      nginx.virtualHosts."seerr.altanen.casa" = {
        useACMEHost = "altanen.casa";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:5055";
          proxyWebsockets = true;
        };
      };
    };
  };
}
