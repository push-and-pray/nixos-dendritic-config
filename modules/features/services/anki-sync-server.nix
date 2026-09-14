{
  flake.modules.nixos.anki-sync-server =
    { config, ... }:
    {
      sops.secrets."qbittorrent/password" = {
        sopsFile = ../../../secrets/qbittorrent.yaml;
      };

      services = {
        anki-sync-server = {
          enable = true;
          address = "127.0.0.1";
          users = [
            {
              username = "julius";
              passwordFile = config.sops.secrets."qbittorrent/password".path;
            }
          ];
        };

        nginx.virtualHosts."anki.altanen.casa" = {
          useACMEHost = "altanen.casa";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:27701";
            extraConfig = ''
              client_max_body_size 500M;
              proxy_read_timeout 600s;
              proxy_send_timeout 600s;
            '';
          };
        };
      };
    };
}
