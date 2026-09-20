{ inputs, ... }: {
  flake.modules.nixos.media-server = {
    imports = with inputs.self.modules.nixos; [
      media-group
      qbittorrent
      sonarr
      radarr
      prowlarr
      recyclarr
      bazarr
      flaresolverr
      jellyfin
      reverse-proxy
    ];

    systemd.tmpfiles.rules = [
      "d /media 0775 root media -"
    ];
  };
}
