_: {
  flake.modules.homeManager.neovim = {pkgs, ...}: {
    programs.neovim.plugins = [
      {
        plugin = pkgs.vimPlugins.nvim-lint;
        optional = true;
      }
    ];
    xdg.configFile."nvim/plugin/lint.lua".source = ./lint.lua;
  };
}
