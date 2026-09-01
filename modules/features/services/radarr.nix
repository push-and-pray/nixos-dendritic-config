{ inputs, ... }: {
  flake.modules.nixos.radarr =
    {
      config,
      lib,
      ...
    }:
    {
      systemd.tmpfiles.rules = [
        "d /media/movies 0770 root media -"
      ];
      imports = [ inputs.self.modules.nixos.media-group ];

      sops = {
        secrets = {
          radarr = {
            sopsFile = ../../../secrets/media-secrets.yaml;
          };
        };
        templates = {
          "radarr_secrets.env" = {
            path = "/run/secrets/radarr_secrets.env";
            content = ''
              RADARR__AUTH__APIKEY=${config.sops.placeholder.radarr}
            '';
          };
        };
      };

      services = {
        radarr = {
          enable = true;
          group = "media";
          environmentFiles = [ "/run/secrets/radarr_secrets.env" ];
        };

        nginx.virtualHosts."radarr.altanen.casa" = {
          useACMEHost = "altanen.casa";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:7878";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_read_timeout 600s;
              proxy_send_timeout 600s;
            '';
          };
        };
      };

      systemd.services.radarr.serviceConfig.UMask = lib.mkForce "0002";
    };
}
