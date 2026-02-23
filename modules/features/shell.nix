{inputs, ...}: {
  flake.modules.homeManager.zsh = {
    programs = {
      zsh = {
        enable = true;
        oh-my-zsh = {
          enable = true;
          theme = "robbyrussell";
        };
      };

      starship = {
        enable = true;
        enableZshIntegration = true;
      };

      direnv.enableZshIntegration = true;
    };
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
