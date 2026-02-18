{inputs, ...}: {
  flake.modules.nixos.desktop = {
    imports = with inputs.self.modules.nixos; [hyprland];
    home-manager.sharedModules = with inputs.self.modules.homeManager; [desktop-apps fonts cli];

    specialisation = {
      default.configuration = {
        imports = with inputs.self.modules.nixos; [hyprlock];
        home-manager.sharedModules = with inputs.self.modules.homeManager; [fuzzel hyprpaper hypridle hyprsunset hyprpolkitagent waybar mako];
      };
      dank.configuration = {
        programs.dms-shell.enable = true;
      };
    };
  };

  flake.modules.homeManager.fonts = {pkgs, ...}: {
    home.packages = with pkgs; [
      adwaita-icon-theme
      noto-fonts
      noto-fonts-cjk-sans
      font-awesome
    ];
  };
}
