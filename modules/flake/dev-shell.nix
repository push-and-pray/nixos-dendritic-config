{
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      inputsFrom = [config.pre-commit.devShell];
      packages = with pkgs; [
        nixos-facter
      ];
    };
  };
}
