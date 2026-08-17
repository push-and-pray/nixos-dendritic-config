_: {
  flake.modules.homeManager.neovim = { pkgs, ... }: {
    stylix.targets.neovim.enable = false;

    home.sessionVariables = {
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
      VISUAL = "nvim";
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      initLua = builtins.readFile ./neovim/init.lua;
      plugins = [ pkgs.vimPlugins.lz-n ];
      withNodeJs = false;
      withPython3 = false;
      withRuby = false;
    };
  };
}
