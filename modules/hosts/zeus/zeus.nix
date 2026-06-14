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
    nixpkgs.hostPlatform = {
      system = "x86_64-linux";
      gcc.arch = "x86-64-v3";
      gcc.tune = "generic";
    };

    # GCC 15 (new default in nixpkgs-unstable) promotes -Wtemplate-id-cdtor to
    # a hard error under C++20, which breaks V8's source in nodejs when
    # building from source (required for x86-64-v3 since the binary cache only
    # covers plain x86_64-linux).
    nixpkgs.overlays = [
      (
        final: prev: let
          addCompatFlag = pkg:
            pkg.overrideAttrs (old: {
              env =
                (old.env or {})
                // {
                  NIX_CXXFLAGS_COMPILE = (old.env.NIX_CXXFLAGS_COMPILE or "") + " -Wno-template-id-cdtor";
                };
            });

          nodejsAttrs = [
            "nodejs"
            "nodejs-slim"
            "nodejs_18"
            "nodejs_20"
            "nodejs_22"
            "nodejs_23"
            "nodejs_24"
          ];
        in
          prev.lib.genAttrs
          (builtins.filter (attr: prev ? ${attr}) nodejsAttrs)
          (attr: addCompatFlag prev.${attr})
      )
      (
        final: prev: {
          pythonPackagesExtensions =
            prev.pythonPackagesExtensions
            ++ [
              (python-final: python-prev: {
                distutils = python-prev.distutils.overridePythonAttrs (old: {
                  doCheck = false;
                });
              })
            ];
        }
      )
    ];
    nix = {
      buildMachines = [
        {
          hostName = "pan";
          protocol = "ssh-ng";
          system = "x86_64-linux";
          sshUser = "julius";
          maxJobs = 3;
          speedFactor = 1;
          publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUF6aXpEeWVSVFB0bTY2dzZOaTFRdlpLUG9VZWdmaGgwaDcxK3pIYXRrWGIgcm9vdEBwYW4K";
          supportedFeatures = ["gccarch-x86-64-v3" "nixos-test" "benchmark" "big-parallel" "kvm"];
        }
        {
          hostName = "192.168.0.3";
          protocol = "ssh-ng";
          system = "x86_64-linux";
          sshUser = "julius";
          maxJobs = 4;
          speedFactor = 2;
          publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUZMRFVlOG9wc1U5dWRzL0xnSmFpTXZKQ2w5b1grOUNEN2JlRWpERHFlcVIgcm9vdEBhcmVzCg==";
          supportedFeatures = ["gccarch-x86-64-v3" "nixos-test" "benchmark" "big-parallel" "kvm"];
        }
      ];
      distributedBuilds = true;
      settings = {
        builders-use-substitutes = true;
        system-features = ["gccarch-x86-64-v3" "nixos-test" "benchmark" "big-parallel" "kvm"];
      };
    };

    programs.ssh.extraConfig = ''
      Host pan 192.168.0.3
        IdentityAgent /run/user/1000/gcr/ssh
    '';

    system.stateVersion = "25.11";
    hardware.facter.reportPath = ./facter.json;

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
          workspace = [
            "2,monitor:DP-1"
            "1,monitor:HDMI-A-2"
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
      stylix
      nix
      julius
    ];
  };
}
