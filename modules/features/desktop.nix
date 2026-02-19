{inputs, ...}: {
  flake.modules.nixos.dank = {
    imports = with inputs.self.modules.nixos; [hyprland network];
    home-manager.sharedModules = with inputs.self.modules.homeManager; [desktop-apps fonts cli dank];

    programs.dms-shell.enable = true;
  };

  flake.modules.homeManager = {
    fonts = {pkgs, ...}: {
      home.packages = with pkgs; [
        adwaita-icon-theme
        noto-fonts
        noto-fonts-cjk-sans
        font-awesome
      ];
    };
    dank = {
      wayland.windowManager.hyprland = {
        settings = {
          bind = [
            "SUPER, space, exec, dms ipc call spotlight toggle"
            "SUPER, V, exec, dms ipc call clipboard toggle"
            "SUPER, comma, exec, dms ipc call settings focusOrToggle"
            "SUPER, N, exec, dms ipc call notifications toggle"
            "SUPER, P, exec, dms ipc call powermenu toggle"
            "SUPER, L, exec, dms ipc call lock lock"
          ];
          bindel = [
            ",XF86MonBrightnessUp, exec, dms ipc call brightness increment 5"
            ",XF86MonBrightnessDown, exec, dms ipc call brightness decrement 5"
            ",XF86AudioRaiseVolume, exec, dms ipc call audio increment 3"
            ",XF86AudioLowerVolume, exec, dms ipc call audio decrement 3"
          ];
          bindl = [
            ",XF86AudioMute, exec, dms ipc call audio mute"
          ];
        };
        extraConfig = ''
          source = ~/.config/hypr/dms/colors.conf
          source = ~/.config/hypr/dms/layout.conf
          source = ~/.config/hypr/dms/outputs.conf
        '';
      };
    };
  };
}
