{
  flake.modules.nixos = {
    ssd = {
      services.fstrim.enable = true;
    };
    zswap = {
      boot.zswap = {
        enable = true;
        compressor = "zstd";
        zpool = "zsmalloc";
      };
    };
    nvidia = {
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware = {
        graphics.enable = true;
        nvidia = {
          open = true;
          modesetting.enable = true;
          powerManagement.enable = false;
        };
        nvidia-container-toolkit.enable = true;
      };
    };
  };
}
