{ inputs, ... }: {
  flake.nixosConfigurations.atlas = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.self.modules.nixos.atlas
      inputs.sops-nix.nixosModules.sops
    ];
  };

  flake.modules.nixos.atlas = { pkgs, ... }: {
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

    networking = {
      hostName = "atlas";
      useDHCP = true;
      useNetworkd = true;
      interfaces.enp86s0.wakeOnLan.enable = true;
    };

    sops.secrets.tailscale-auth-key.key = "ts-key-atlas";

    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 16384;
      }
    ];

    imports = with inputs.self.modules.nixos; [
      server
      intel
      ssd
      zswap
      media-server
      notes
      actual
      attic
      beszel
      ntfy
    ];
  };
}
