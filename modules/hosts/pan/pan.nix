{ inputs, ... }: {
  flake.nixosConfigurations.pan = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.self.modules.nixos.pan
      inputs.sops-nix.nixosModules.sops
    ];
  };

  flake.modules.nixos.pan = { pkgs, ... }: {
    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "26.05";
    hardware.facter.reportPath = ./facter.json;

    # amd/firmware handle CPU microcode; pan additionally needs GPU
    # transcode support that desktop hosts sharing `amd` don't want.
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [ rocmPackages.clr.icd ];
    };

    nix.settings = {
      system-features = [
        "gccarch-x86-64-v3"
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];

      substituters = [
        "https://cache.nixos.org?priority=10"
        "https://nix-community.cachix.org?priority=15"
        "https://install.determinate.systems?priority=20"
      ];

      auto-optimise-store = true;

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM"
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      download-buffer-size = 1024 * 1024 * 256;

      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
        dates = "daily";
      };
    };

    security.sudo.wheelNeedsPassword = false;
    users.users.julius = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialHashedPassword = "$6$gmrWDM.J6mO4zmDN$nEa2XN.lzTMvnt6YI9qmm2v6.LRrHO7wA4mXQF/c7H1tKxXkW7IHXJojizlOFd90gI8LzeSLqLGwnLf2yLj5x1";
      openssh.authorizedKeys.keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIL27EDkViSsAa6PByx7ZaqAg2CgL3V1Wiy6RmQ/StegbAAAABHNzaDo= julius@zeus"
      ];
    };

    services.tailscale = {
      enable = true;
      authKeyFile = "/run/secrets/ts-key";
      port = 41641;
      openFirewall = true;
      extraSetFlags = [
        "--relay-server-port=40000"
        "--relay-server-static-endpoints=185.107.13.2:40000"
      ];
    };
    networking = {
      firewall.allowedUDPPorts = [ 40000 ];
      hostName = "pan";
      interfaces.enp1s0.wakeOnLan.enable = true;
    };

    sops.secrets.ts-key = {
      sopsFile = ../../../secrets/ts-key.yaml;
    };

    services = {
      nginx = {
        virtualHosts = {
          "notes.altanen.casa" = {
            forceSSL = true;
            locations = {
              "/" = {
                proxyPass = "http://127.0.0.1:3030";
                proxyWebsockets = true;
              };
            };
            useACMEHost = "altanen.casa";
          };
        };
      };
      openssh = {
        enable = true;
      };
      silverbullet = {
        enable = true;
        listenPort = 3030;
      };
    };

    environment.enableAllTerminfo = true;
    environment.systemPackages = with pkgs; [ neovim ];

    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 32768;
      }
    ];

    imports = with inputs.self.modules.nixos; [
      locale
      systemd-boot
      amd
      ssd
      zswap
      qbittorrent
      sonarr
      radarr
      prowlarr
      recyclarr
      bazarr
      flaresolverr
      jellyfin
      actual
      attic
      beszel
      reverse-proxy
      sops
    ];
  };
}
