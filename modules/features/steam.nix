_: {
  flake.modules.nixos.steam = {pkgs, ...}: {
    programs = {
      gamemode = {
        enable = true;
        settings = {
          general = {renice = 10;};
          gpu = {
            apply_gpu_optimisations = "accept-responsibility";
            gpu_device = 0;
            nv_powermizer_mode = 1;
          };
        };
      };
      gamescope = {
        capSysNice = false;
        enable = true;
      };
      steam = {
        dedicatedServer = {openFirewall = true;};
        enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
        gamescopeSession = {
          args = ["-O" "DP-1"];
          enable = true;
        };
        remotePlay = {openFirewall = true;};
      };
    };

    environment.systemPackages = with pkgs; [
      mangohud
    ];
  };
}
