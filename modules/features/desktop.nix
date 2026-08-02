{inputs, ...}: {
  flake.modules.nixos.dank = {
    pkgs,
    lib,
    ...
  }: {
    imports = with inputs.self.modules.nixos; [hyprland network keyring];
    home-manager.sharedModules = with inputs.self.modules.homeManager; [desktop-apps fonts cli dank];

    environment.systemPackages = with pkgs; [
      libnotify
      qt6.qtmultimedia
    ];

    programs.dms-shell = {
      enable = true;
      enableCalendarEvents = false;
      enableDynamicTheming = false;
      plugins = {
        dankPomodoroTimer = {
          enable = true;
          src = "${pkgs.fetchFromGitHub {
            owner = "AvengeMedia";
            repo = "dms-plugins";
            rev = "master";
            hash = "sha256-/155wFIotV9xiZzX9XRGs3ANjBcLJwS4kNDDNO6WkF0=";
          }}/DankPomodoroTimer";
        };
        fossilizeMonitor = {
          enable = true;
          src = ./plugins/fossilizeMonitor;
        };
      };
    };
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
    dank = {lib, ...}: {
      home.pointerCursor.enable = true;
      wayland.windowManager.hyprland = {
        settings = {
          bind = [
            {
              _args = [
                "SUPER + space"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"dms ipc call spotlight toggle\")")
              ];
            }
            {
              _args = [
                "SUPER + V"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"dms ipc call clipboard toggle\")")
              ];
            }
            {
              _args = [
                "SUPER + comma"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"dms ipc call settings focusOrToggle\")")
              ];
            }
            {
              _args = [
                "SUPER + N"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"dms ipc call notifications toggle\")")
              ];
            }
            {
              _args = [
                "SUPER + P"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"dms ipc call powermenu toggle\")")
              ];
            }
            {
              _args = [
                "SUPER + L"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"dms ipc call lock lock\")")
              ];
            }

            {
              _args = [
                "XF86MonBrightnessUp"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"dms ipc call brightness increment 5\")")
                {
                  locked = true;
                  repeating = true;
                }
              ];
            }
            {
              _args = [
                "XF86MonBrightnessDown"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"dms ipc call brightness decrement 5\")")
                {
                  locked = true;
                  repeating = true;
                }
              ];
            }
            {
              _args = [
                "XF86AudioRaiseVolume"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"dms ipc call audio increment 3\")")
                {
                  locked = true;
                  repeating = true;
                }
              ];
            }
            {
              _args = [
                "XF86AudioLowerVolume"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"dms ipc call audio decrement 3\")")
                {
                  locked = true;
                  repeating = true;
                }
              ];
            }
            {
              _args = [
                "XF86AudioMute"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"dms ipc call audio mute\")")
                {locked = true;}
              ];
            }
          ];
        };
        extraConfig = ''
          pcall(require, "dms.colors")
          pcall(require, "dms.layout")
          pcall(require, "dms.outputs")
          pcall(require, "dms.windowrules")
        '';
      };
    };
  };
}
