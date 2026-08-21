{ inputs, ... }: {
  flake.modules.nixos.sonarr =
    {
      config,
      lib,
      ...
    }:
    {
      systemd.tmpfiles.rules = [
        "d /media/shows 0770 root media -"
      ];
      imports = [ inputs.self.modules.nixos.media-group ];

      sops = {
        secrets = {
          sonarr = {
            sopsFile = ../../../secrets/media-secrets.yaml;
          };
        };
        templates = {
          "sonarr_secrets.env" = {
            path = "/run/secrets/sonarr_secrets.env";
            content = ''
              SONARR__AUTH__APIKEY=${config.sops.placeholder.sonarr}
            '';
          };
        };
      };

      services = {
        sonarr = {
          enable = true;
          group = "media";
          environmentFiles = [ "/run/secrets/sonarr_secrets.env" ];
        };
      };

      systemd.services.sonarr.serviceConfig.UMask = lib.mkForce "0002";
    };
}
