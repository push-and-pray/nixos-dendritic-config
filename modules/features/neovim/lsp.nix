_: {
  flake.modules.homeManager.neovim = {pkgs, ...}: {
    programs.neovim.plugins = with pkgs.vimPlugins; [
      blink-cmp
      friendly-snippets
      nvim-lspconfig
      {
        plugin = fidget-nvim;
        optional = true;
      }
    ];
    xdg.configFile."nvim/plugin/lsp.lua".source = ./lsp.lua;
  };
}
