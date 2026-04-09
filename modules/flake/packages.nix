_: {
  perSystem = {pkgs, ...}: {
    packages.elemental = pkgs.callPackage ../../pkgs/elemental.nix {};
  };
}
