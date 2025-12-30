{inputs, ...}: let
  user = "julius";
  inherit (inputs.self.lib) dockerAccess zsh admin;
in {
  flake.modules.nixos.julius = {
    imports = [
      (dockerAccess user)
      (admin user)
      (zsh user)
    ];

    users.users.${user} = {
      isNormalUser = true;
    };

    home-manager.users.${user} = {
      home.username = user;
      home.homeDirectory = "/home/${user}";
    };
  };
}
