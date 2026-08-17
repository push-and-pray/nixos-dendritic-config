{ inputs, ... }: {
  imports = [
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem = {
    pre-commit = {
      settings.hooks = {
        nixfmt.enable = true;
        statix.enable = true;
        flake-checker.enable = true;
      };
    };
  };
}
