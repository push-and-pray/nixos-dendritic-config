{ inputs, ... }: {
  flake.modules.nixos.media-server = {
    imports = with inputs.self.modules.nixos; [
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
  };
}
