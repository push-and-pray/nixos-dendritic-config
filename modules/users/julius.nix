{inputs, ...}: let
  user = "julius";
  inherit (inputs.self.lib) zsh;
in {
  flake.modules.nixos.julius = {
    imports = [
      (zsh user)
    ];

    users.users.${user} = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "docker" "video" "i2c"];
    };

    home-manager.users.${user} = {
      home.username = user;
      home.homeDirectory = "/home/${user}";
    };
  };
}
