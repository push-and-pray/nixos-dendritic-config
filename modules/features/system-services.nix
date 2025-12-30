{inputs, ...}: {
  flake.modules = {
    homeManager = {
      diskManagement = {
        services.udiskie.enable = true;
      };

      bluetooth = {
        services.blueman-applet.enable = true;
      };
    };

    nixos = {
      twingate = {
        services.twingate.enable = true;
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
  };
}
