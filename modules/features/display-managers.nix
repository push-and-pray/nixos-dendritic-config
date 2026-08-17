{
  flake.modules.nixos = {
    tuigreet =
      {
        pkgs,
        config,
        ...
      }:
      {
        services.greetd = {
          enable = true;
          settings = {
            default_session =
              let
                sessionShare = "${config.services.displayManager.sessionData.desktops}/share";
              in
              {
                command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions ${sessionShare}/wayland-sessions";
                user = "greeter";
              };
          };
          useTextGreeter = true;
        };
      };
    ly = {
      services.displayManager.ly = {
        enable = true;
      };
    };
  };
}
