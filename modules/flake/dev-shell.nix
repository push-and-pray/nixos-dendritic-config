{
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        inputsFrom = [ config.pre-commit.devShell ];
        packages = with pkgs; [
          deadnix
          statix
          nixd
          nixfmt
          nixos-facter
          nix-output-monitor
          stylua
        ];
      };
    };
}
