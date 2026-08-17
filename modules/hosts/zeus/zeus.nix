{ inputs, ... }: {
  flake.nixosConfigurations.zeus = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.self.modules.nixos.zeus
    ];
  };

  flake.modules.nixos.zeus =
    {
      config,
      pkgs,
      ...
    }:
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      system.stateVersion = "25.11";
      hardware.facter.reportPath = ./facter.json;

      nix = {
        settings = {
          system-features = [ "uid-range" ];
          experimental-features = [
            "auto-allocate-uids"
            "cgroups"
          ];
          auto-allocate-uids = true;
        };
        distributedBuilds = true;
        buildMachines = [
          {
            hostName = "localhost:2222";
            maxJobs = 2;
            publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVB5SjlWem1IVDEwSzkybm1xWnVlTVc5MExrWm9oVmtBbEkwZzc1SlM0ZUU=";
            system = "x86_64-linux";
            supportedFeatures = [
              "big-parallel"
              "kvm"
              "benchmark"
            ];
            protocol = "ssh-ng";
          }
        ];
      };

      services.udev.packages = with pkgs; [
        platformio-core.udev
        openocd
      ];

      networking = {
        hostName = "zeus";
        interfaces = {
          enp5s0.wakeOnLan.enable = true;
          wlo1.wakeOnLan.enable = true;
        };
      };

      services.hardware.openrgb = {
        enable = true;
        package = pkgs.openrgb-with-all-plugins;
      };

      home-manager.sharedModules = [
        {
          wayland.windowManager.hyprland.settings = {
            monitor = [
              (pkgs.lib.generators.mkLuaInline "{ output = \"DP-1\", mode = \"2560x1440@143.972\", position = \"0x0\", scale = 1, vrr = 1, bitdepth = 10 }")
              (pkgs.lib.generators.mkLuaInline "{ output = \"HDMI-A-2\", mode = \"2560x1440@144.006\", position = \"-1440x-720\", transform = 1, scale = 1, vrr = 1, bitdepth = 10 }")
            ];
            workspace_rule = [
              (pkgs.lib.generators.mkLuaInline "{ workspace = \"2\", monitor = \"DP-1\" }")
              (pkgs.lib.generators.mkLuaInline "{ workspace = \"1\", monitor = \"HDMI-A-2\" }")
            ];
          };
        }
        inputs.self.modules.homeManager.matlab
      ];

      hardware.i2c.enable = true;
      boot.zswap.enable = true;

      imports = with inputs.self.modules.nixos; [
        locale
        systemd-boot
        tuigreet
        sound
        intel
        ssd
        nvidia
        docker
        dank
        steam
        homeManager
        tailscale
        yubi
        tpm
        stylix
        nix
        julius
      ];
    };
}
