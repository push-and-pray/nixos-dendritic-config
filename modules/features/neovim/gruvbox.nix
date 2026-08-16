_: {
  flake.modules.homeManager.neovim = {pkgs, ...}: {
    programs.neovim.plugins = [pkgs.vimPlugins.gruvbox-nvim];
    xdg.configFile."nvim/plugin/gruvbox.lua".source = ./gruvbox.lua;
  };
}
