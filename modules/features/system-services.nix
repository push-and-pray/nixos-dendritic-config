{inputs, ...}: {
  flake.modules = {
    nixos = {
      twingate = {
        services.twingate.enable = true;
      };
      tailscale = {
        services.tailscale.enable = true;
      };
      ssh = {
        services.openssh.enable = true;
      };
      systemSvc = {
        imports = with inputs.self.modules.nixos; [
          diskManagement
          keyring
          bluetooth
          network
        ];
      };

      diskManagement = {
        services.udisks2.enable = true;
        programs.gnome-disks.enable = true;

        home-manager.sharedModules = [
          inputs.self.modules.homeManager.diskManagement
        ];
      };

      keyring = {pkgs, ...}: {
        services.gnome.gnome-keyring.enable = true;
        programs.seahorse.enable = true;

        nixpkgs.overlays = [
          (final: prev: {
            element-desktop = prev.element-desktop.override {
              commandLineArgs = "--password-store=\"gnome-libsecret\"";
            };
          })
        ];

        home-manager.sharedModules = [
          {
            home.file.".vscode/argv.json".text = builtins.toJSON {
              "password-store" = "gnome-libsecret";
              "enable-crash-reporter" = false;
            };
          }
          {
            programs.git = {
              package = pkgs.gitFull;
              settings = {
                credential = {
                  helper = "libsecret";
                };
              };
            };
          }
        ];
      };

      bluetooth = {
        services = {
          blueman.enable = true;
        };
        home-manager.sharedModules = [
          inputs.self.modules.homeManager.bluetooth
        ];
      };

      network = {
        networking = {
          networkmanager.enable = true;
          dhcpcd.enable = false;
        };
      };
    };

    homeManager = {
      diskManagement = {
        services.udiskie.enable = true;
      };

      bluetooth = {
        services.blueman-applet.enable = true;
      };
    };
  };
}
