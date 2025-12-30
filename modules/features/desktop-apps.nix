{inputs, ...}: {
  flake.modules.homeManager = {
    desktop-apps = {
      imports = with inputs.self.modules.homeManager; [
        spotify
        firefox
        vscode
        fuzzel
        kitty
      ];
    };
    spotify = {pkgs, ...}: {
      home.packages = with pkgs; [spotify];
    };
    firefox = {
      programs.firefox = {
        enable = true;
        profiles.default.extensions.force = true;
      };
    };
    vscode = {
      programs.vscode = {
        enable = true;
      };
    };
    fuzzel = {
      programs.fuzzel = {
        enable = true;
      };
    };
    kitty = {
      programs.kitty = {
        enable = true;
      };
    };
  };
}
