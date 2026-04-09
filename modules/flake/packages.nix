_: {
  perSystem = {pkgs, ...}: {
    packages.elemental = pkgs.callPackage ../../pkgs/elemental.nix {};
    packages.sam-ba = pkgs.callPackage ../../pkgs/sam-ba.nix {};
  };
}
