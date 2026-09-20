{ inputs, ... }: {
  flake.nixosConfigurations.pan = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.self.modules.nixos.pan
      inputs.sops-nix.nixosModules.sops
    ];
  };

  flake.modules.nixos.pan = { pkgs, ... }: {
    system.stateVersion = "26.05";
    hardware.facter.reportPath = ./facter.json;

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [ rocmPackages.clr.icd ];
    };

    nix.settings = {
      system-features = [
        "gccarch-x86-64-v3"
      ];
    };

    networking = {
      hostName = "pan";
      useDHCP = true;
      useNetworkd = true;
      interfaces.enp1s0.wakeOnLan.enable = true;
    };

    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 32768;
      }
    ];

    imports = with inputs.self.modules.nixos; [
      server
      amd
      ssd
      zswap
      beszel-agent
    ];
  };
}
