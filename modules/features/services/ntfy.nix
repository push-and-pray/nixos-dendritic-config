{
  flake.modules.nixos.ntfy = {
    services.ntfy-sh = {
      enable = true;

      settings = {
        base-url = "https://ntfy.altanen.casa";
        listen-http = "127.0.0.1:2586";
        behind-proxy = true;
        upstream-base-url = "https://ntfy.sh";
      };
    };
  };
}
