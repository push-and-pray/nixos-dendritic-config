_: {
  flake.modules.homeManager.neovim = { pkgs, ... }: {
    programs.neovim.plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-dap;
        optional = true;
      }
      {
        plugin = nvim-dap-view;
        optional = true;
      }
      {
        plugin = nvim-dap-disasm;
        optional = true;
      }
    ];
    xdg.configFile."nvim/plugin/dap.lua".source = ./dap.lua;
  };
}
