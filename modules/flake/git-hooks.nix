{inputs, ...}: {
  imports = [
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem = {config, ...}: {
    pre-commit = {
      settings.hooks = {
        alejandra.enable = true;
        deadnix.enable = true;
        statix.enable = true;
      };
    };

    devShells.default = config.pre-commit.devShell;
  };
}
