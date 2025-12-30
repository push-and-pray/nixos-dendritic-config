{
  flake.modules.homeManager.mako = {pkgs, ...}: {
    services.mako = {
      enable = true;
      settings = {
        default-timeout = 10000;
      };
    };

    home.packages = with pkgs; [
      libnotify
    ];
  };
}
