_: {
  flake.modules.homeManager.neovim = { pkgs, ... }: {
    programs.neovim = {
      extraPackages = with pkgs; [
        fd
        lazygit
        ripgrep
        xdg-utils
      ];
      plugins = [ pkgs.vimPlugins.snacks-nvim ];
    };
    xdg.configFile."nvim/plugin/snacks.lua".source = ./snacks.lua;
  };
}
