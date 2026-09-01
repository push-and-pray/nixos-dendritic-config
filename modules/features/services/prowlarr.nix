{
  flake.modules.nixos.prowlarr = {
    services = {
      prowlarr = {
        enable = true;
      };

      nginx.virtualHosts."prowlarr.altanen.casa" = {
        useACMEHost = "altanen.casa";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9696";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_read_timeout 600s;
            proxy_send_timeout 600s;
          '';
        };
      };
    };
  };
}
