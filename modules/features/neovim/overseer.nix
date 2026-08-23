_: {
  flake.modules.homeManager.neovim = { pkgs, ... }: {
    programs.neovim.plugins = [
      {
        plugin = pkgs.vimPlugins.overseer-nvim;
        optional = true;
      }
    ];
    xdg.configFile."nvim/plugin/overseer.lua".source = ./overseer.lua;
  };
}
