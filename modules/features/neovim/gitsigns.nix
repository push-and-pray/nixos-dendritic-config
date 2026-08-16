_: {
  flake.modules.homeManager.neovim = {pkgs, ...}: {
    programs.neovim.plugins = [
      {
        plugin = pkgs.vimPlugins.gitsigns-nvim;
        optional = true;
      }
    ];
    xdg.configFile."nvim/plugin/gitsigns.lua".source = ./gitsigns.lua;
  };
}
