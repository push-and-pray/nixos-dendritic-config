{
  flake.modules.nixos = {
    reverse-proxy = { config, ... }: {
      users.users.nginx.extraGroups = [ "acme" ];

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      security.acme = {
        acceptTerms = true;
      };

      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;

        virtualHosts."_" = {
          default = true;
          useACMEHost = "altanen.casa";
          forceSSL = true;
          locations."/" = {
            return = "404 \"404 Not Found\n\"";
            extraConfig = ''
              default_type text/plain;
            '';
          };
        };
      };

      sops.secrets = {
        cloudflare = {
          sopsFile = ../../secrets/cloudflare.yaml;
        };
      };

      sops.templates = {
        "cloudflare.env" = {
          path = "/run/secrets/cloudflare.env";
          content = ''
            CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."cloudflare"}
          '';
        };
      };

      security.acme.certs."altanen.casa" = {
        domain = "altanen.casa";
        extraDomainNames = [ "*.altanen.casa" ];
        dnsProvider = "cloudflare";
        environmentFile = "/run/secrets/cloudflare.env";
      };
    };

    qbittorrent = {
      services.nginx = {
        virtualHosts."qbittorrent.altanen.casa" = {
          useACMEHost = "altanen.casa";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://192.168.0.100:8080";
            proxyWebsockets = true;
          };
        };
      };
    };

    upsnap = {
      services.nginx = {
        virtualHosts."upsnap.altanen.casa" = {
          useACMEHost = "altanen.casa";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8090";
            proxyWebsockets = true;
          };
        };
      };
    };

    sonarr = {
      services.nginx = {
        virtualHosts."sonarr.altanen.casa" = {
          useACMEHost = "altanen.casa";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8989";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_read_timeout 600s;
              proxy_send_timeout 600s;
            '';
          };
        };
      };
    };
    radarr = {
      services.nginx = {
        virtualHosts."radarr.altanen.casa" = {
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
    };
    bazarr = {
      services.nginx = {
        virtualHosts."bazarr.altanen.casa" = {
          useACMEHost = "altanen.casa";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:6767";
            proxyWebsockets = true;
          };
        };
      };
    };
    prowlarr = {
      services.nginx = {
        virtualHosts."prowlarr.altanen.casa" = {
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
    flaresolverr = {
      services.nginx = {
        virtualHosts."flaresolverr.altanen.casa" = {
          useACMEHost = "altanen.casa";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8191";
            proxyWebsockets = true;
          };
        };
      };
    };
    jellyfin = {
      services.nginx = {
        virtualHosts."jellyfin.altanen.casa" = {
          useACMEHost = "altanen.casa";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8096";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_buffering off;
            '';
          };
        };
        virtualHosts."seerr.altanen.casa" = {
          useACMEHost = "altanen.casa";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:5055";
            proxyWebsockets = true;
          };
        };
      };
    };
    actual = {
      services.nginx = {
        virtualHosts."actual.altanen.casa" = {
          useACMEHost = "altanen.casa";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:3000";
            proxyWebsockets = true;
          };
        };
      };
    };
    attic = {
      services.nginx = {
        virtualHosts."attic.altanen.casa" = {
          useACMEHost = "altanen.casa";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:4321";
            extraConfig = ''
              client_max_body_size 0;
              proxy_request_buffering off;
              proxy_read_timeout 600s;
              proxy_send_timeout 600s;
            '';
          };
        };
      };
    };
  };
}
