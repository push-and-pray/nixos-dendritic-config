{inputs, ...}: {
  flake.modules.homeManager.zsh = {
    config,
    lib,
    ...
  }: {
    programs.zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
      };
    };

    programs.direnv.enableZshIntegration = lib.mkIf config.programs.direnv.enable true;
  };

  flake.lib = {
    zsh = username: {pkgs, ...}: {
      programs.zsh.enable = true;
      users.users.${username}.shell = pkgs.zsh;

      home-manager.users.${username} = {
        imports = [inputs.self.modules.homeManager.zsh];
      };
    };
  };
}
