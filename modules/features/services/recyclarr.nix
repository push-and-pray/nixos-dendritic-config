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

              quality_definition = {
                type = "series";
              };

              quality_profiles = [
                {
                  trash_id = "72dae194fc92bf828f32cde7744e51a1";
                  reset_unmatched_scores.enabled = true;
                }
                {
                  trash_id = "9d142234e45d6143785ac55f5a9e8dc9";
                  reset_unmatched_scores.enabled = true;
                }
                {
                  trash_id = "d1498e7d189fbe6c7110ceaabb7473e6";
                  reset_unmatched_scores.enabled = true;
                }
                {
                  trash_id = "20e0fc959f1f1704bed501f23bdae76f";
                  reset_unmatched_scores.enabled = true;
                }
              ];

              custom_formats = [
                {
                  trash_ids = [
                    "418f50b10f1907201b6cfdf881f467b7"
                  ];
                  assign_scores_to = [
                    {
                      name = "[Anime] Remux-1080p";
                      score = 500;
                    }
                  ];
                }
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

              media_naming = {
                folder = "jellyfin-tmdb";
                movie = {
                  rename = true;
                  standard = "jellyfin-tmdb";
                };
              };

              quality_definition = {
                type = "movie";
              };

              quality_profiles = [
                {
                  trash_id = "d1d67249d3890e49bc12e275d989a7e9";
                  reset_unmatched_scores.enabled = true;
                }
                {
                  trash_id = "9ca12ea80aa55ef916e3751f4b874151";
                  reset_unmatched_scores.enabled = true;
                }
                {
                  trash_id = "64fb5f9858489bdac2af690e27c8f42f";
                  reset_unmatched_scores.enabled = true;
                }
                {
                  trash_id = "722b624f9af1e492284c4bc842153a38";
                  reset_unmatched_scores.enabled = true;
                }
              ];

              custom_formats = [
                {
                  trash_ids = [
                    "4a3b087eea2ce012fcc1ce319259a3be"
                  ];
                  assign_scores_to = [
                    {
                      name = "[Anime] Remux-1080p";
                      score = 500;
                    }
                  ];
                }
              ];
            };
          };
        };
      };
    };
  };
}
