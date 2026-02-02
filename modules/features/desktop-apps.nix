{inputs, ...}: {
  flake.modules.homeManager = {
    desktop-apps = {
      imports = with inputs.self.modules.homeManager; [
        spotify
        firefox
        vscode
        fuzzel
        kitty
        signal
        discord
        surfer
        drawio
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
    signal = {pkgs, ...}: {
      home.packages = with pkgs; [signal-desktop];
    };
    discord = {pkgs, ...}: {
      home.packages = with pkgs; [discord];
    };
    surfer = {pkgs, ...}: {
      home.packages = with pkgs; [surfer];
    };
    drawio = {pkgs, ...}: {
      home.packages = with pkgs; [drawio];
    };
  };
}
