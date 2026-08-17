_: {
  flake.modules.homeManager.neovim = { pkgs, ... }: {
    programs.neovim.plugins = [
      {
        plugin = pkgs.vimPlugins.flash-nvim;
        optional = true;
      }
    ];
    xdg.configFile."nvim/plugin/flash.lua".source = ./flash.lua;
  };
}
