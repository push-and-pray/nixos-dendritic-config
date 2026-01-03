{inputs, ...}: {
  flake.modules = {
    nixos = {
      nightShiftDdc = {
        hardware.i2c = {
          enable = true;
        };

        home-manager.sharedModules = [
          inputs.self.modules.homeManager.gammastep
          inputs.self.modules.homeManager.gammastepDdcHook
        ];
      };
    };

    homeManager = {
      gammastep = {
        services.gammastep = {
          enable = true;
          provider = "manual";
          latitude = 55.6;
          longitude = 12.5;
          temperature = {
            day = 6500;
            night = 2500;
          };
        };
      };
      gammastepDdcHook = {pkgs, ...}: {
        xdg.configFile."gammastep/hooks/dimmer.sh" = {
          executable = true;
          source = pkgs.writeShellScript "dimmer_hook" ''
            DDCUTIL="${pkgs.ddcutil}/bin/ddcutil"

            case $2 in
              night)
                $DDCUTIL setvcp 10 10 --display 1
                $DDCUTIL setvcp 10 10 --display 2
                ;;
              day)
                $DDCUTIL setvcp 10 70 --display 1
                $DDCUTIL setvcp 10 70 --display 2
                ;;
            esac
          '';
        };
      };
    };
  };
}
