{ inputs, ... }: {
  flake.modules.nixos.nix = { pkgs, ... }: {
    nix.settings = {
      substituters = [
        "https://cache.lan.altanen.casa?priority=10"
        "https://cache.lan.altanen.casa/nix-community?priority=15"
        "https://cache.lan.altanen.casa/push-and-pray?priority=15"

        "https://cache.nixos.org?priority=30"
        "https://nix-community.cachix.org?priority=35"
        "https://push-and-pray-config.cachix.org?priority=35"
      ];

      auto-optimise-store = true;

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "push-and-pray-config.cachix.org-1:O8IdCd6x5jFWH+jvvJ6Tn6iWPchHRSPpDTODZ/FLqlk="
      ];

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      download-buffer-size = 1024 * 1024 * 256;

      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 30d --keep 3";
      flake = "~/dev/nix/os/";
    };
  };
}
