{
  flake.modules.nixos.ares = {
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/981e2aed-b34b-436a-9bf8-8eba9e3e54b0";
      fsType = "ext4";
    };

    boot.initrd.luks.devices."luks-8d1d18b4-3391-4b63-8437-8fc62437b026".device = "/dev/disk/by-uuid/8d1d18b4-3391-4b63-8437-8fc62437b026";

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/EE6D-31BE";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
  };
}
