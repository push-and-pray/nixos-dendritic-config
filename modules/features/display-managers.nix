{
  flake.modules.nixos = {
    tuigreet = {pkgs, ...}: {
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time";
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
