{inputs, ...}: let
  user = "julius";
  inherit (inputs.self.lib) dockerAccess zsh admin;
in {
  flake.modules.nixos.julius = {config, ...}: {
    imports = [
      (dockerAccess user)
      (admin user)
      (zsh user)
    ];

    users.users.${user} = {
      isNormalUser = true;
      extraGroups = [config.hardware.i2c.group];
    };

    home-manager.users.${user} = {
      home.username = user;
      home.homeDirectory = "/home/${user}";
    };
  };
}
