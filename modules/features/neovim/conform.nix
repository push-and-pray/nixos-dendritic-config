_: {
  flake.modules.homeManager.neovim = {pkgs, ...}: {
    programs.neovim.plugins = [
      {
        plugin = pkgs.vimPlugins.conform-nvim;
        optional = true;
      }
    ];
    xdg.configFile."nvim/plugin/conform.lua".source = ./conform.lua;
  };
}
