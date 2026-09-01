{
  flake.modules.nixos.attic =
    {
      config,
      pkgs,
      ...
    }:
    {
      services.atticd = {
        enable = true;
        environmentFile = config.sops.templates."attic.env".path;
        settings = {
          listen = "[::]:4321";
          api-endpoint = "https://attic.altanen.casa/";
          storage = {
            type = "s3";
            region = "auto";
            bucket = "nix-cache";
            endpoint = "https://c18fd1edf973013bda63c635a44e9a47.r2.cloudflarestorage.com";
          };
          chunking = {
            nar-size-threshold = 1048576;
            min-size = 1048576;
            avg-size = 4194304;
            max-size = 16777216;
          };
          garbage-collection = {
            interval = "12 hours";
            default-retention-period = "2 weeks";
          };
        };
      };

      environment.systemPackages = with pkgs; [
        attic-client
      ];

      services.nginx.virtualHosts."attic.altanen.casa" = {
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

      sops.secrets = {
        "attic/jwt_secret" = {
          sopsFile = ../../../secrets/attic.yaml;
        };
        "attic/aws_access_key_id" = {
          sopsFile = ../../../secrets/attic.yaml;
        };
        "attic/aws_secret_access_key" = {
          sopsFile = ../../../secrets/attic.yaml;
        };
      };

      sops.templates."attic.env" = {
        content = ''
          ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64=${config.sops.placeholder."attic/jwt_secret"}
          AWS_ACCESS_KEY_ID=${config.sops.placeholder."attic/aws_access_key_id"}
          AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."attic/aws_secret_access_key"}
        '';
      };
    };
}
