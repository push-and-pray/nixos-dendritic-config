_: {
  perSystem = {pkgs, ...}: {
    packages = {
      elemental = pkgs.callPackage ../../pkgs/elemental.nix {};
      sam-ba = pkgs.callPackage ../../pkgs/sam-ba.nix {};
      matlab = pkgs.callPackage ../../pkgs/matlab-fhs.nix {};
    };
  };
}
