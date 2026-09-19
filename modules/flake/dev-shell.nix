{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      config,
      system,
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
          inputs.colmena.packages.${system}.colmena
          stylua
          sops
        ];
      };
    };
}
