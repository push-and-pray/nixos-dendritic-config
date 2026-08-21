{
  flake.modules.nixos.recyclarr = { config, ... }: {
    sops.secrets = {
      sonarr = {
        sopsFile = ../../../secrets/media-secrets.yaml;
      };
      radarr = {
        sopsFile = ../../../secrets/media-secrets.yaml;
      };
    };

    services = {
      recyclarr = {
        enable = true;
        configuration = {
          sonarr = {
            shows = {
              base_url = "https://sonarr.altanen.casa";
              api_key = {
                _secret = config.sops.secrets.sonarr.path;
              };
              delete_old_custom_formats = true;
              replace_existing_custom_formats = true;

              media_naming = {
                series = "jellyfin-tvdb";
                season = "default";
                episodes = {
                  rename = true;
                  standard = "default";
                  daily = "default";
                  anime = "default";
                };
              };

              include = [
                { template = "sonarr-quality-definition-anime"; }

                { template = "sonarr-v4-quality-profile-web-1080p"; }
                { template = "sonarr-v4-quality-profile-anime"; }

                { template = "sonarr-v4-custom-formats-anime"; }
                { template = "sonarr-v4-custom-formats-web-1080p"; }
              ];
            };
          };
          radarr = {
            movies = {
              base_url = "https://radarr.altanen.casa";
              api_key = {
                _secret = config.sops.secrets.radarr.path;
              };

              delete_old_custom_formats = true;
              replace_existing_custom_formats = true;

              media_naming = {
                folder = "jellyfin-tmdb";
                movie = {
                  rename = true;
                  standard = "jellyfin-tmdb";
                };
              };

              include = [
                { template = "radarr-quality-definition-movie"; }

                { template = "radarr-custom-formats-anime"; }
                { template = "radarr-quality-profile-anime"; }

                { template = "radarr-custom-formats-hd-bluray-web"; }
                { template = "radarr-quality-profile-hd-bluray-web"; }
              ];
            };
          };
        };
      };
    };
  };
}
