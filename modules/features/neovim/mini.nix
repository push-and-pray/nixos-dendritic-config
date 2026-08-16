_: {
  flake.modules.homeManager.neovim = {pkgs, ...}: {
    programs.neovim.plugins = [pkgs.vimPlugins.mini-nvim];
    xdg.configFile."nvim/plugin/mini.lua".source = ./mini.lua;
  };
}
