{inputs, ...}: {
  flake.modules.nixos = {
    intel = {
      imports = with inputs.self.modules.nixos; [
        firmware
      ];
      hardware.cpu.intel.updateMicrocode = true;
    };

    amd = {
      imports = with inputs.self.modules.nixos; [
        firmware
      ];
      hardware.cpu.amd.updateMicrocode = true;
    };

    firmware = {
      hardware.enableAllFirmware = true;
      nixpkgs.config.allowUnfree = true;

      services.fwupd.enable = true;
      services.udisks2.enable = true;
    };
  };
}
