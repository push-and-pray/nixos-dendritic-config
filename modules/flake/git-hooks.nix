{inputs, ...}: {
  imports = [
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem = {
    pre-commit = {
      settings.hooks = {
        alejandra.enable = true;
        statix.enable = true;
        flake-checker.enable = true;
      };
    };
  };
}
