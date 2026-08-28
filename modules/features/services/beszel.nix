{
  flake.modules.nixos.beszel = {
    services.beszel = {
      hub = {
        enable = true;
        host = "127.0.0.1";
        port = 8090;
      };

      agent = {
        enable = true;

        environment = {
          LISTEN = "127.0.0.1:45876";

          KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJshyKXyMb9W1xxPZfS9rUU1XcqTaG7MGPqchuUq7aBD";

          GPU_COLLECTOR = "amd_sysfs";
        };

        smartmon.enable = true;
      };
    };
  };
}
