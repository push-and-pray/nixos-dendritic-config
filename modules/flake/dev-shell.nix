{
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      inputsFrom = [config.pre-commit.devShell];
      packages = with pkgs; [
        deadnix
        nixd
        nixos-facter
        nix-output-monitor
        stylua
      ];
    };
  };
}
