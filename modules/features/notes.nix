{
  flake.modules.nixos.notes = {
    services = {
      nginx.virtualHosts."notes.altanen.casa" = {
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3030";
          proxyWebsockets = true;
        };
        useACMEHost = "altanen.casa";
      };

      silverbullet = {
        enable = true;
        listenPort = 3030;
      };
    };
  };
}
