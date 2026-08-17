{ inputs, ... }: {
  flake.modules = {
    nixos = {
      yubi = { pkgs, ... }: {
        # ssh-keygen -t ed25519-sk -O resident -C "julius@zeus"
        services.udev.packages = [ pkgs.libfido2 ];
        environment.systemPackages = [ pkgs.yubikey-manager ];
        services.gnome.gcr-ssh-agent.enable = false;
        programs.ssh.startAgent = true;
        programs.yubikey-touch-detector.enable = true;
      };

      tpm = {
        # ssh-tpm-keygen -t ecdsa -C "julius@zeus"
        security.tpm2.enable = true;
        services.gnome.gcr-ssh-agent.enable = false;
        programs.ssh.startAgent = true;

        home-manager.sharedModules = [
          inputs.self.modules.homeManager.tpm
        ];
      };
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

      keyring = { pkgs, ... }: {
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
      tpm = { osConfig, ... }: {
        # -A chains to openssh's agent, so this one socket serves both
        # tpm and sk keys.
        services.ssh-tpm-agent = {
          enable = true;
          extraArgs = [
            "-A"
            "%t/ssh-agent"
          ];
        };

        # ssh-tpm-agent only probes hardcoded /usr askpass paths, so without
        # this it can't prompt for the key passphrase and refuses to sign.
        systemd.user.services.ssh-tpm-agent.Service.Environment = [
          "SSH_ASKPASS=${osConfig.programs.ssh.askPassword}"
        ];
      };

      diskManagement = {
        services.udiskie.enable = true;
      };

      bluetooth = {
        services.blueman-applet.enable = true;
      };
    };
  };
}
