{ inputs, ... }:
let
  mkNode = hostname: module: {
    imports = [
      module
      inputs.sops-nix.nixosModules.sops
    ];

    deployment = {
      targetHost = hostname;
      targetUser = "julius";
    };
  };
in
{
  flake.colmena = {
    meta.nixpkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
    };

    pan = mkNode "pan" inputs.self.modules.nixos.pan;
    atlas = mkNode "atlas" inputs.self.modules.nixos.atlas;
  };

  flake.colmenaHive = inputs.colmena.lib.makeHive inputs.self.colmena;
}
