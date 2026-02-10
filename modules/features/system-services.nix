{inputs, ...}: {
  flake.modules = {
    nixos = {
      twingate = {
        services.twingate.enable = true;
      };
      tailscale = {
        services.tailscale.enable = true;
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

      keyring = {
        services.gnome.gnome-keyring.enable = true;
        programs.seahorse.enable = true;

        home-manager.sharedModules = [
          {
            home.file.".vscode/argv.json".text = builtins.toJSON {
              "password-store" = "gnome-libsecret";
              "enable-crash-reporter" = false;
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
