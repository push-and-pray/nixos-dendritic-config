{
  flake.modules.nixos.docker = {pkgs, ...}: {
    virtualisation = {
      docker = {
        enable = true;
        autoPrune.enable = true;
      };
    };

    users.users.julius = {
      extraGroups = [
        "docker"
      ];
    };

    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
          podman-bootc
        ];
      }
    ];
  };
}
