{
  flake.modules.nixos.beszel = {
    services.beszel = {
      hub = {
        enable = true;
        host = "127.0.0.1";
        port = 8090;

        environment = {
          APP_URL = "https://health.altanen.casa";
        };
      };

      agent = {
        enable = true;

        environment = {
          LISTEN = "127.0.0.1:45876";
          KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJshyKXyMb9W1xxPZfS9rUU1XcqTaG7MGPqchuUq7aBD";
          GPU_COLLECTOR = "amd_sysfs";
          AUTO_LOGIN = "admin@altanen.casa";
        };

        smartmon.enable = true;
      };
    };

    services.nginx.virtualHosts."health.altanen.casa" = {
      useACMEHost = "altanen.casa";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8090";
        proxyWebsockets = true;
      };
    };
  };
}
