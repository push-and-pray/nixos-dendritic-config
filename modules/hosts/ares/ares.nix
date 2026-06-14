{inputs, ...}: {
  flake.nixosConfigurations.ares = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.self.modules.nixos.ares
    ];
  };

  flake.modules.nixos.ares = {
    config,
    pkgs,
    ...
  }: {
    nixpkgs.hostPlatform = "x86_64-linux";
    nix.settings.system-features = ["gccarch-x86-64-v3" "nixos-test" "benchmark" "big-parallel" "kvm"];
    system.stateVersion = "25.05";
    hardware.facter.reportPath = ./facter.json;
    networking.hostName = "ares";

    boot = {
      # nixos-facter mislabels my ethernet device
      extraModulePackages = [config.boot.kernelPackages.yt6801];
      kernelModules = ["yt6801"];
    };

    services = {
      udev.packages = with pkgs; [
        platformio-core.udev
        openocd
      ];
      power-profiles-daemon.enable = true;
      upower.enable = true;
    };

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

      inputs.self.modules.homeManager.matlab
    ];

    imports = with inputs.self.modules.nixos; [
      locale
      systemd-boot
      tuigreet
      sound
      amd
      ssd
      docker
      dank
      homeManager
      tailscale
      ssh
      libvirt
      stylix
      nix
      julius
    ];
  };
}
