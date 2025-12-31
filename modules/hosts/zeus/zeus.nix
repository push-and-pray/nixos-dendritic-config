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

    home-manager.sharedModules = [
      {
        wayland.windowManager.hyprland.settings = {
          monitor = [
            "DP-1,preferred,0x0,1"
            "HDMI-A-2,preferred,-1440x-700,1,transform,1"
          ];
          workspace = [
            "2,monitor:DP-1"
            "1,monitor:HDMI-A-2"
          ];
        };
      }
    ];

    imports = with inputs.self.modules.nixos; [
      locale
      systemd-boot
      tuigreet
      sound
      intel
      ssd
      nvidia
      zram
      docker
      desktop
      homeManager
      twingate
      stylix
      nix
      julius
    ];
  };
}
