{inputs, ...}: {
  flake.nixosConfigurations.ares = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.self.modules.nixos.ares
    ];
  };

  flake.modules.nixos.ares = {config, ...}: {
    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "25.05";
    hardware.facter.reportPath = ./facter.json;
    networking.hostName = "ares";

    boot = {
      # nixos-facter mislabels my ethernet device
      extraModulePackages = [config.boot.kernelPackages.yt6801];
      kernelModules = ["yt6801"];
      kernelParams = [
        "amd_pstate=active"
      ];
    };

    services.power-profiles-daemon.enable = true;

    # Boost startup speed
    virtualisation.docker.enableOnBoot = false;
    systemd.services.NetworkManager-wait-online.enable = false;

    home-manager.sharedModules = [
      {
        wayland.windowManager.hyprland.settings = {
          monitor = [
            ",preferred,auto,1.6"
          ];
        };
      }
    ];

    imports = with inputs.self.modules.nixos; [
      locale
      systemd-boot
      tuigreet
      sound
      amd
      ssd
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
