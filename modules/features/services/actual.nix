{
  flake.modules.nixos.actual = {
    services = {
      actual = {
        enable = true;
        settings.hostname = "127.0.0.1";
      };

      nginx.virtualHosts."actual.altanen.casa" = {
        useACMEHost = "altanen.casa";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3000";
          proxyWebsockets = true;
        };
      };
    };
  };
}
