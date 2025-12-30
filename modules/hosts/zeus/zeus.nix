{inputs, ...}: {
  flake.nixosConfigurations.zeus = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.self.modules.nixos.zeus
    ];
  };

  flake.modules.nixos.zeus = {
    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "25.11";
    hardware.facter.reportPath = ./facter.json;
    networking.hostName = "zeus";
    imports = with inputs.self.modules.nixos; [
      locale
      systemd-boot
      ly
      sound
      intel
      ssd
      nvidia
      zram
      docker
      desktop
      homeManager
      systemSvc
      twingate
      stylix
      julius
    ];
  };
}
