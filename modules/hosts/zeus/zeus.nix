{inputs, ...}: {
  flake.nixosConfigurations.zeus = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.self.modules.nixos.zeus
    ];
  };

  flake.modules.nixos.zeus = {
    config,
    pkgs,
    ...
  }: {
    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "25.11";
    hardware.facter.reportPath = ./facter.json;

    networking = {
      hostName = "zeus";
      interfaces = {
        enp5s0.wakeOnLan.enable = true;
        wlo1.wakeOnLan.enable = true;
      };
    };

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

    hardware.i2c.enable = true;

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
      tailscale
      stylix
      nix
      julius
    ];
  };
}
