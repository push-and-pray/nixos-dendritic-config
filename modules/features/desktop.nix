{inputs, ...}: {
  flake.modules.nixos.desktop = {
    imports = with inputs.self.modules.nixos; [hyprland hyprlock];
    home-manager.sharedModules = with inputs.self.modules.homeManager; [hyprpaper hypridle hyprpolkitagent waybar mako desktop-apps cli];
  };
}
