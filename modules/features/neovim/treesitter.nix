_: {
  flake.modules.homeManager.neovim = {pkgs, ...}: {
    programs.neovim.plugins = [
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (parsers:
        with parsers; [
          bash
          c
          go
          java
          lua
          markdown
          markdown_inline
          nix
          python
          query
          rust
          scala
          vim
          vimdoc
          yaml
          zig
        ]))
    ];
    xdg.configFile."nvim/plugin/treesitter.lua".source = ./treesitter.lua;
  };
}
