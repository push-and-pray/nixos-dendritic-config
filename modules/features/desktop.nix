{inputs, ...}: {
  flake.modules.nixos.desktop = {
    imports = with inputs.self.modules.nixos; [hyprland network];
    home-manager.sharedModules = with inputs.self.modules.homeManager; [desktop-apps fonts cli];

    specialisation = {
      default.configuration = {
        imports = with inputs.self.modules.nixos; [hyprlock systemSvc];
        home-manager.sharedModules = with inputs.self.modules.homeManager; [fuzzel hyprpaper hypridle hyprsunset hyprpolkitagent waybar mako];
      };
      dank.configuration = {lib, ...}: {
        programs.dms-shell.enable = true;

        home-manager.sharedModules = [
          {
            services.hyprpaper.enable = lib.mkForce false;
            home.sessionVariables = {
              ELECTRON_OZONE_PLATFORM_HINT = "auto";
              QT_QPA_PLATFORMTHEME = lib.mkForce "gtk3";
              QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
            };
            wayland.windowManager.hyprland.extraConfig = ''
              source = ~/.config/hypr/dms/colors.conf
              source = ~/.config/hypr/dms/layout.conf
              source = ~/.config/hypr/dms/outputs.conf

              $mod = SUPER

              # Application Launchers
              bind = $mod, space, exec, dms ipc call spotlight toggle
              bind = $mod, V, exec, dms ipc call clipboard toggle
              bind = $mod, M, exec, dms ipc call processlist focusOrToggle
              bind = $mod, comma, exec, dms ipc call settings focusOrToggle
              bind = $mod, N, exec, dms ipc call notifications toggle
              bind = $mod, Y, exec, dms ipc call dankdash wallpaper
              bind = $mod, TAB, exec, dms ipc call hypr toggleOverview

              # Security
              bind = $mod ALT, L, exec, dms ipc call lock lock

              # Audio Controls
              bindel = , XF86AudioRaiseVolume, exec, dms ipc call audio increment 3
              bindel = , XF86AudioLowerVolume, exec, dms ipc call audio decrement 3
              bindl = , XF86AudioMute, exec, dms ipc call audio mute

              # Brightness Controls
              bindel = , XF86MonBrightnessUp, exec, dms ipc call brightness increment 5
              bindel = , XF86MonBrightnessDown, exec, dms ipc call brightness decrement 5
            '';
          }
        ];
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
