_: {
  perSystem = {pkgs, ...}: {
    packages.bcvk = pkgs.callPackage ../../packages/bcvk.nix {};
  };
}
