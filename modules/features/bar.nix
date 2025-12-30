{
  flake.modules.homeManager = {
    waybar = {
      pkgs,
      config,
      ...
    }: {
      home.packages = with pkgs; [
        playerctl
        brightnessctl
        blueman
      ];
      programs.waybar = {
        enable = true;
        settings = [
          {
            spacing = 10;
            fixed-center = true;
            modules-left = [
              "hyprland/workspaces"
              "cava"
              "pulseaudio"
              "mpris"
            ];
            modules-center = [
              "clock"
              "idle_inhibitor"
            ];
            modules-right = [
              "cpu"
              "memory"
              "temperature"
              "backlight"
              "network"
              "bluetooth"
              "battery"
            ];
            "hyprland/workspaces" = {
              format = "|{icon}|";
            };
            "cava" = {
              hide_on_silence = false;
              framerate = 60;
              bars = 10;
              format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
              sleep_timer = 5;
              bar_delimiter = 0;
            };
            "mpris" = {
              format = "{status_icon} {title} - {artist}";
              player-icons = {
                default = "▶";
                spotify = "";
                firefox = "";
              };
              status-icons = {
                paused = "⏸";
                playing = "";
              };
            };
            "idle_inhibitor" = {
              format = "{icon}";
              format-icons = {
                activated = "󰥔";
                deactivated = "";
              };
            };
            "temperature" = {
              thermal-zone = 12;
              critical-threshold = 85;
              format = "{icon} {temperatureC}°C";
              format-icons = ["" "" "" "" "" "⚠"];
              format-critical = "{icon}{icon} {temperatureC}°C";
              interval = 10;
            };
            clock = {
              "format" = "{:%H:%M}";
              "format-alt" = "{:%A, %B %d, %Y (%R)}";
              "tooltip-format" = "<tt><small>{calendar}</small></tt>";
            };
            cpu = {
              min-length = 6;
              format = " {usage}%";
              tooltip = true;
            };
            memory = {
              min-length = 6;
              format = " {}%";
            };
            backlight = {
              format = "{icon} {percent}%";
              format-icons = ["" "" "" "" "" "" "" "" ""];
              on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set 2%+";
              on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 2%-";
            };
            network = {
              format-wifi = "󰤨 Wi-Fi";
              format-ethernet = "󱘖 Wired";
              format-linked = "󱘖 {ifname} (No IP)";
              format-disconnected = "󰤮 Off";
              tooltip-format = "󱘖 {ipaddr}  {bandwidthUpBytes}  {bandwidthDownBytes}";
            };
            bluetooth = {
              format = "";
              format-connected = " {num_connections}";
              tooltip-format = " {device_alias}";
              tooltip-format-connected = "{device_enumerate}";
              tooltip-format-enumerate-connected = " {device_alias}";
              on-click = "${pkgs.blueman}/bin/blueman-manager";
            };
            pulseaudio = {
              format = "{icon} {volume}%";
              format-muted = " ";
              on-click = "${pkgs.pavucontrol}/bin/pavucontrol -t 3";
              tooltip-format = "{icon} {desc} // {volume}%";
              scroll-step = 4;
              format-icons = {
                headphone = "";
                hands-free = "";
                headset = "";
                phone = "";
                portable = "";
                car = "";
                default = ["" "" ""];
              };
            };

            "pulseaudio#microphone" = {
              format = "{format_source}";
              format-source = " {volume}%";
              format-source-muted = "";
              on-click = "pavucontrol -t 4";
              tooltip-format = "{format_source} {source_desc} // {source_volume}%";
              scroll-step = 5;
            };
            battery = {
              states = {
                good = 95;
                warning = 30;
                critical = 20;
              };
              format = "{icon} {capacity}%";
              format-charging = " {capacity}%";
              format-plugged = " {capacity}%";
              format-icons = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
            };
          }
        ];
      };
      systemd.user.services.waybar = {
        Unit = {
          Description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
          Documentation = "https://github.com/Alexays/Waybar/wiki";
          After = ["graphical-session.target"];
        };

        Service = {
          ExecStart = "${config.programs.waybar.package}/bin/waybar";
          ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
          Restart = "on-failure";
          KillMode = "mixed";
          Slice = "app-graphical.slice";
        };

        Install = {WantedBy = ["graphical-session.target"];};
      };
    };
  };
}
