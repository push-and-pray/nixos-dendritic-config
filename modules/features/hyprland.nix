{inputs, ...}: {
  flake.modules = {
    nixos = {
      hyprland = {pkgs, ...}: {
        programs.hyprland = {
          enable = true;
          withUWSM = true;
        };
        environment.systemPackages = with pkgs; [
          qt6.qtwayland
          libsForQt5.qt5.qtwayland
        ];
        environment.sessionVariables = {
          NIXOS_OZONE_WL = "1";

          GDK_BACKEND = "wayland,x11,*";
          CLUTTER_BACKEND = "wayland";
          SDL_VIDEODRIVER = "wayland";

          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_TYPE = "wayland";
          XDG_SESSION_DESKTOP = "Hyprland";

          QT_AUTO_SCREEN_SCALE_FACTOR = "1";
          QT_QPA_PLATFORM = "wayland;xcb";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          QT_QPA_PLATFORMTHEME = "qt5ct";
        };

        home-manager.sharedModules = [
          inputs.self.modules.homeManager.hyprland
        ];
      };

      hyprlock = {
        security.pam.services.hyprlock = {};
        home-manager.sharedModules = [
          inputs.self.modules.homeManager.hyprlock
        ];
      };
    };

    homeManager = {
      hyprpaper = {
        services.hyprpaper.enable = true;
      };

      hyprpolkitagent = {
        services.hyprpolkitagent.enable = true;
      };

      hypridle = {
        services.hypridle = {
          enable = true;
          settings = {
            general = {
              lock_cmd = "pidof hyprlock || hyprlock";
              before_sleep_cmd = "loginctl lock-session";
              after_sleep_cmd = "hyprctl dispatch dpms on";
            };
            listener = [
              {
                timeout = 100;
                on-timeout = "brightnessctl -s set 2%";
                on-resume = "brightnessctl -r";
              }
              {
                timeout = 230;
                on-timeout = "notify-send 'Locking screen soon...'";
              }
              {
                timeout = 240;
                on-timeout = "loginctl lock-session";
              }
              {
                timeout = 300;
                on-timeout = "hyprctl dispatch dpms off";
                on-resume = "hyprctl dispatch dpms on";
              }
            ];
          };
        };
      };

      hyprlock = {
        programs.hyprlock = {
          enable = true;
          settings = {
            general = {
              disable_loading_bar = true;
              hide_cursor = true;
            };
            background = [
              {
                path = "screenshot";
                blur_passes = 3;
                blur_size = 8;
              }
            ];
            input-field = [
              {
                monitor = "";
                size = "400, 100";
                position = "0, -80";
                placeholder_text = "Password...";
              }
            ];
          };
        };
      };

      hyprland = {
        pkgs,
        lib,
        ...
      }: {
        imports = [
          inputs.self.modules.homeManager.fuzzel
        ];

        home.packages = with pkgs; [
          brightnessctl
          playerctl
          wl-clipboard
        ];

        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = false;
          settings = {
            monitor = lib.mkDefault ", preferred, auto, 1";
            input = {
              kb_layout = "dk";
            };

            bind = [
              "SUPER,Return,exec,kitty"
              "SUPER,Space,exec,${pkgs.fuzzel}/bin/fuzzel --launch-prefix='uwsm app --'"
              "SUPER, L, exec,hyprlock"

              ",XF86MonBrightnessDown,exec,brightnessctl set 20%-"
              ",XF86MonBrightnessUp,exec,brightnessctl set +20%"
              ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"
              ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"
              ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
              ", XF86AudioPlay, exec, playerctl play-pause"

              "SUPER,q,killactive"
              "SUPER,f,fullscreen"

              "SUPER,Right,movefocus,r"
              "SUPER,Left,movefocus,l"
              "SUPER,Up,movefocus,u"
              "SUPER,Down,movefocus,d"

              "SUPER_SHIFT,Right,movewindow,r"
              "SUPER_SHIFT,Left,movewindow,l"
              "SUPER_SHIFT,Up,movewindow,u"
              "SUPER_SHIFT,Down,movewindow,d"

              "SUPER,1,workspace,1"
              "SUPER,2,workspace,2"
              "SUPER,3,workspace,3"
              "SUPER,4,workspace,4"
              "SUPER,5,workspace,5"
              "SUPER,6,workspace,6"
              "SUPER,7,workspace,7"
              "SUPER,8,workspace,8"
              "SUPER,9,workspace,9"
              "SUPER,0,workspace,10"

              "SUPER_SHIFT,1,movetoworkspacesilent,1"
              "SUPER_SHIFT,2,movetoworkspacesilent,2"
              "SUPER_SHIFT,3,movetoworkspacesilent,3"
              "SUPER_SHIFT,4,movetoworkspacesilent,4"
              "SUPER_SHIFT,5,movetoworkspacesilent,5"
              "SUPER_SHIFT,6,movetoworkspacesilent,6"
              "SUPER_SHIFT,7,movetoworkspacesilent,7"
              "SUPER_SHIFT,8,movetoworkspacesilent,8"
              "SUPER_SHIFT,9,movetoworkspacesilent,9"
              "SUPER_SHIFT,0,movetoworkspacesilent,10"

              "SUPER,minus,togglespecialworkspace,scratchpad"
              "SUPER_SHIFT,minus,movetoworkspacesilent,special:scratchpad"
            ];

            workspace = [
              "special:scratchpad,gapsout:75,gapsin:10"
            ];

            misc = {
              disable_hyprland_logo = true;
            };
          };
        };
      };
    };
  };
}
