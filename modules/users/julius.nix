{inputs, ...}: let
  user = "julius";
  inherit (inputs.self.lib) zsh;
in {
  flake.modules.nixos.julius = {config, ...}: {
    imports = [
      (zsh user)
    ];

    users.users.${user} = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "docker" config.hardware.i2c.group];
    };

    home-manager.users.${user} = {
      home.username = user;
      home.homeDirectory = "/home/${user}";
    };
  };
}
