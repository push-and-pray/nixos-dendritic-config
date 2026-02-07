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

    boot.extraModulePackages = [config.boot.kernelPackages.ddcci-driver];
    boot.kernelModules = ["ddcci_backlight"];
    environment.systemPackages = [pkgs.brightnessctl];
    hardware.i2c.enable = true;

    systemd.services."ddcci-attach@" = {
      description = "Probe ddcci-backlight on %I";
      serviceConfig = {
        Type = "oneshot";
        After = ["systemd-modules-load.service"];
      };

      scriptArgs = "%i";

      script = ''
        I2C_DEV="$1"
        DEV_PATH="/sys/bus/i2c/devices/$I2C_DEV"
        NAME_FILE="$DEV_PATH/name"
        NEW_DEV_FILE="$DEV_PATH/new_device"
        DEL_DEV_FILE="$DEV_PATH/delete_device"

        BUS_NUM=''${I2C_DEV#i2c-}
        DEVICE_DIR="$DEV_PATH/$BUS_NUM-0037"

        if [ ! -f "$NAME_FILE" ]; then exit 0; fi

        I2C_NAME=$(cat "$NAME_FILE")

        if echo "$I2C_NAME" | grep -qiE "nvidia|amdgpu|radeon|i915|gmbus|drm|ddc"; then
          echo "ddcci-handler: Detected display bus $I2C_DEV ($I2C_NAME)."

          for i in 1 2 3; do
            echo "ddcci-handler: Attempt $i..."

            # Clean up if the directory exists but is broken
            if [ -d "$DEVICE_DIR" ]; then
               echo "ddcci-handler: Cleaning up existing device..."
               echo 0x37 > "$DEL_DEV_FILE" 2>/dev/null || true
               sleep 1
            fi

            # Create the device
            echo ddcci 0x37 > "$NEW_DEV_FILE" 2>/dev/null || true

            # Wait for driver to populate folders
            sleep 3

            # verify success by looking for the 'backlight' folder inside the device
            if find "$DEVICE_DIR" -name "backlight" | grep -q "backlight"; then
              echo "ddcci-handler: Success! Backlight detected on $I2C_DEV."
              exit 0
            else
              echo "ddcci-handler: Device attached, but path not found. Contents of $DEVICE_DIR:"
              ls -R "$DEVICE_DIR" || echo "Directory missing"
            fi

            echo "ddcci-handler: Retrying in 5 seconds..."
            sleep 5
          done

          echo "ddcci-handler: Failed to enable backlight on $I2C_DEV after 3 attempts."
          # Clean up so we don't leave a zombie
          echo 0x37 > "$DEL_DEV_FILE" 2>/dev/null || true
          exit 1
        fi
      '';
    };

    services.udev.extraRules = ''
      SUBSYSTEM=="i2c", ACTION=="add", TAG+="systemd", ENV{SYSTEMD_WANTS}+="ddcci-attach@$kernel.service"
    '';

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
