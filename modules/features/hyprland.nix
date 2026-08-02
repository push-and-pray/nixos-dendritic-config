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
          qt5.qtwayland
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
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          _JAVA_AWT_WM_NONREPARENTING = "1";
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

      fuzzel = {
        pkgs,
        lib,
        ...
      }: {
        wayland.windowManager.hyprland.settings.bind = [
          {
            _args = [
              "SUPER + Space"
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${pkgs.fuzzel}/bin/fuzzel --launch-prefix='uwsm app --'\")")
            ];
          }
        ];
      };

      hyprland = {
        pkgs,
        lib,
        ...
      }: {
        home.packages = with pkgs; [
          brightnessctl
          playerctl
          wl-clipboard
          hyprshot
        ];

        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = false;
          configType = "lua";
          settings = {
            monitor = lib.mkDefault (lib.generators.mkLuaInline "{ output = \"\", mode = \"preferred\", position = \"auto\", scale = \"1\" }");
            config.input = {
              kb_layout = "dk";
            };

            bind = [
              {
                _args = [
                  "SUPER + q"
                  (lib.generators.mkLuaInline "hl.dsp.window.close()")
                ];
              }
              {
                _args = [
                  "SUPER + f"
                  (lib.generators.mkLuaInline "hl.dsp.window.fullscreen()")
                ];
              }

              {
                _args = [
                  "SUPER + Right"
                  (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"r\" })")
                ];
              }
              {
                _args = [
                  "SUPER + Left"
                  (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"l\" })")
                ];
              }
              {
                _args = [
                  "SUPER + Up"
                  (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"u\" })")
                ];
              }
              {
                _args = [
                  "SUPER + Down"
                  (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"d\" })")
                ];
              }

              {
                _args = [
                  "SUPER + SHIFT + Right"
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ direction = \"r\" })")
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + Left"
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ direction = \"l\" })")
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + Up"
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ direction = \"u\" })")
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + Down"
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ direction = \"d\" })")
                ];
              }

              {
                _args = [
                  "SUPER + 1"
                  (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"1\" })")
                ];
              }
              {
                _args = [
                  "SUPER + 2"
                  (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"2\" })")
                ];
              }
              {
                _args = [
                  "SUPER + 3"
                  (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"3\" })")
                ];
              }
              {
                _args = [
                  "SUPER + 4"
                  (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"4\" })")
                ];
              }
              {
                _args = [
                  "SUPER + 5"
                  (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"5\" })")
                ];
              }
              {
                _args = [
                  "SUPER + 6"
                  (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"6\" })")
                ];
              }
              {
                _args = [
                  "SUPER + 7"
                  (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"7\" })")
                ];
              }
              {
                _args = [
                  "SUPER + 8"
                  (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"8\" })")
                ];
              }
              {
                _args = [
                  "SUPER + 9"
                  (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"9\" })")
                ];
              }
              {
                _args = [
                  "SUPER + 0"
                  (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"10\" })")
                ];
              }

              {
                _args = [
                  "SUPER + SHIFT + 1"
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ silent = true, workspace = \"1\" })")
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + 2"
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ silent = true, workspace = \"2\" })")
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + 3"
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ silent = true, workspace = \"3\" })")
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + 4"
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ silent = true, workspace = \"4\" })")
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + 5"
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ silent = true, workspace = \"5\" })")
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + 6"
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ silent = true, workspace = \"6\" })")
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + 7"
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ silent = true, workspace = \"7\" })")
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + 8"
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ silent = true, workspace = \"8\" })")
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + 9"
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ silent = true, workspace = \"9\" })")
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + 0"
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ silent = true, workspace = \"10\" })")
                ];
              }

              {
                _args = [
                  "SUPER + minus"
                  (lib.generators.mkLuaInline "hl.dsp.workspace.toggle_special(\"scratchpad\")")
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + minus"
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ silent = true, workspace = \"special:scratchpad\" })")
                ];
              }

              {
                _args = [
                  "Print"
                  (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${pkgs.hyprshot}/bin/hyprshot -m region --clipboard-only\")")
                ];
              }
            ];

            workspace_rule = [
              (lib.generators.mkLuaInline "{ workspace = \"special:scratchpad\", gaps_out = 75, gaps_in = 10 }")
            ];
          };
        };
      };
    };
  };
}
