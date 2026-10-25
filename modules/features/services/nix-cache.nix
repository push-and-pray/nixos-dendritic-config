{
  flake.modules.nixos.nix-cache = {
    services.nginx = {
      appendHttpConfig = ''
        proxy_cache_path /var/cache/nginx/nix levels=1:2 keys_zone=nix_cache:50m max_size=100g inactive=180d use_temp_path=off;
      '';

      virtualHosts."cache.lan.altanen.casa" = {
        useACMEHost = "altanen.casa";
        forceSSL = true;

        extraConfig = ''
          proxy_cache nix_cache;
          proxy_cache_valid 200 302 180d;
          proxy_cache_valid 404 1m;
          proxy_cache_lock on;
          proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
          proxy_ignore_headers "Set-Cookie" "X-Accel-Expires" "Expires" "Cache-Control";
          proxy_ssl_server_name on;
          add_header X-Cache-Status $upstream_cache_status always;
        '';

        locations = {
          "/" = {
            proxyPass = "https://cache.nixos.org";
            recommendedProxySettings = false;
            extraConfig = "proxy_set_header Host cache.nixos.org;";
          };
          "/nix-community/" = {
            proxyPass = "https://nix-community.cachix.org/";
            recommendedProxySettings = false;
            extraConfig = "proxy_set_header Host nix-community.cachix.org;";
          };
          "/push-and-pray/" = {
            proxyPass = "https://push-and-pray-config.cachix.org/";
            recommendedProxySettings = false;
            extraConfig = "proxy_set_header Host push-and-pray-config.cachix.org;";
          };
        };
      };
    };
  };
}
