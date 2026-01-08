{inputs, ...}: {
  flake.modules.nixos.desktop = {
    imports = with inputs.self.modules.nixos; [hyprland hyprlock systemSvc];
    home-manager.sharedModules = with inputs.self.modules.homeManager; [hyprpaper hypridle hyprsunset hyprpolkitagent waybar mako desktop-apps fonts cli];
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
