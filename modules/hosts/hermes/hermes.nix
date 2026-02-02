{inputs, ...}: {
  flake.nixosConfigurations.hermes = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.self.modules.nixos.hermes
    ];
  };

  flake.modules.nixos.hermes = {config, ...}: {
    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "25.05";
    networking.hostName = "hermes";

    home-manager.sharedModules = with inputs.self.modules.homeManager; [
      cli
    ];

    imports = with inputs.self.modules.nixos; [
      locale
      docker
      homeManager
      stylix
      nix
      wsl
      julius
    ];
  };
}
