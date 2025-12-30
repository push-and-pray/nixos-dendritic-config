{
  flake.modules.nixos.zeus = {
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/01e53ebc-66e4-4242-a657-ed7bd151f420";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/F155-1F67";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    swapDevices = [
      {device = "/dev/disk/by-uuid/74776a97-c77d-4752-8dab-920fadbcbdff";}
    ];
  };
}
