{inputs, ...}: {
  flake.modules.nixos.homeManager = {config, ...}: {
    imports = [inputs.home-manager.nixosModules.home-manager];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      sharedModules = [
        {
          home.stateVersion = config.system.stateVersion;
          programs.home-manager.enable = true;
        }
      ];
    };
  };
}
