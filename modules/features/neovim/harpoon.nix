_: {
  flake.modules.homeManager.neovim = {pkgs, ...}: {
    programs.neovim.plugins = with pkgs.vimPlugins; [
      plenary-nvim
      {
        plugin = harpoon2;
        optional = true;
      }
    ];
    xdg.configFile."nvim/plugin/harpoon.lua".source = ./harpoon.lua;
  };
}
