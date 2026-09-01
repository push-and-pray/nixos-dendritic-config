{
  flake.modules.nixos.flaresolverr = {
    services = {
      flaresolverr = {
        enable = true;
      };

      nginx.virtualHosts."flaresolverr.altanen.casa" = {
        useACMEHost = "altanen.casa";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8191";
          proxyWebsockets = true;
        };
      };
    };
  };
}
