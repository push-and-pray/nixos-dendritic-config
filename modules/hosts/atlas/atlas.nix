{ inputs, ... }: {
  flake.nixosConfigurations.atlas = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.self.modules.nixos.atlas
      inputs.sops-nix.nixosModules.sops
    ];
  };

  flake.modules.nixos.atlas = { config, pkgs, ... }: {
    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "26.11";
    hardware.facter.reportPath = ./facter.json;

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-compute-runtime
        vpl-gpu-rt
      ];
    };

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    networking = {
      hostName = "atlas";
      useDHCP = true;
      useNetworkd = true;
    };

    environment.enableAllTerminfo = true;

    security.sudo.wheelNeedsPassword = false;
    users.users.julius = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPiaayaWR+KgD/2gUke5ll5ZKHMLnTJx/3bfc2522qiQ julius@ares"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIL27EDkViSsAa6PByx7ZaqAg2CgL3V1Wiy6RmQ/StegbAAAABHNzaDo= julius@zeus"
      ];
    };

    services.openssh.settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
    services.tailscale = {
      authKeyFile = config.sops.secrets.ts-key-atlas.path;
      openFirewall = true;
    };

    sops.secrets.ts-key-atlas = {
      sopsFile = ../../../secrets/ts-key.yaml;
    };

    imports = with inputs.self.modules.nixos; [
      nix
      locale
      ssh
      tailscale
      sops
    ];
  };
}
