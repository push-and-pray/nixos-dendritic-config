{
  flake.modules.nixos.ntfy = {
    services.ntfy-sh = {
      enable = true;

      settings = {
        base-url = "https://ntfy.altanen.casa";
        listen-http = "127.0.0.1:2586";
        behind-proxy = true;
        upstream-base-url = "https://ntfy.sh";
      };
    };

    services.nginx.virtualHosts."ntfy.altanen.casa" = {
      useACMEHost = "altanen.casa";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:2586";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 20m;
          proxy_buffering off;
          proxy_connect_timeout 3m;
          proxy_read_timeout 3m;
          proxy_send_timeout 3m;
        '';
      };
    };
  };
}
