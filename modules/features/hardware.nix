{
  flake.modules.nixos = {
    ssd = {
      services.fstrim.enable = true;
    };
    nvidia = {
      services.xserver.videoDrivers = ["nvidia"];
      hardware = {
        graphics.enable = true;
        nvidia = {
          open = true;
          modesetting.enable = true;
        };
      };
    };
    zram = {
      zramSwap.enable = true;
    };
  };
}
