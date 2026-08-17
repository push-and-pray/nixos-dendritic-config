_: {
  flake.modules.homeManager.neovim = { pkgs, ... }: {
    programs.neovim.plugins = [
      {
        plugin = pkgs.vimPlugins.which-key-nvim;
        optional = true;
      }
    ];
    xdg.configFile."nvim/plugin/which-key.lua".source = ./which-key.lua;
  };
}
