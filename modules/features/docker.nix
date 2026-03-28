{
  flake.modules.nixos.docker = {pkgs, ...}: {
    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    users.users.julius = {
      extraGroups = [
        "podman"
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
