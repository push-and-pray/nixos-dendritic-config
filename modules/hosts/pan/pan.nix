{ inputs, ... }: {
  flake.nixosConfigurations.pan = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.self.modules.nixos.pan
      inputs.sops-nix.nixosModules.sops
    ];
  };

  flake.modules.nixos.pan = { config, pkgs, ... }: {
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

    services.github-runners.pan = {
      enable = true;
      url = "https://github.com/Dumb-Projects-Inc/os-challenge-makenomistakes";
      tokenFile = config.sops.secrets.github-runner-token.path;
      extraLabels = [ "pan" ];
      extraPackages = with pkgs; [
        util-linux
        jq
      ];
    };

    sops.secrets.github-runner-token = {
      sopsFile = ../../../secrets/github-runner.yaml;
      key = "token";
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
