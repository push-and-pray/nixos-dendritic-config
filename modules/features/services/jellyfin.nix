{ inputs, ... }: {
  flake.modules.nixos.jellyfin = { pkgs, ... }: {
    imports = [ inputs.self.modules.nixos.media-group ];
    users.users.jellyfin.extraGroups = [
      "video"
      "render"
    ];

    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];

    systemd.tmpfiles.rules = [
      "d /var/cache/jellyfin/transcodes 0755 jellyfin media -"
      "d /var/cache/jellyfin/mesa 0755 jellyfin media -"
    ];

    fileSystems."/var/cache/jellyfin/transcodes" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "size=20G"
        "mode=0755"
        "nosuid"
        "nodev"
        "noexec"
      ];
    };

    services = {
      jellyfin = {
        enable = true;
        group = "media";
      };

      nginx.virtualHosts."jellyfin.altanen.casa" = {
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
    };

    systemd.services.jellyfin = {
      environment = {
        # The service's home is /var/empty, so Mesa cannot create its default
        # shader cache and RADV recompiles pipelines on every transcode.
        MESA_SHADER_CACHE_DIR = "/var/cache/jellyfin/mesa";
      };
    };
  };
}
