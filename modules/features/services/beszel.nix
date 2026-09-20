{
  flake.modules.nixos.beszel = { pkgs, ... }: {
    services.beszel = {
      hub = {
        enable = true;
        host = "127.0.0.1";
        port = 8090;

        environment = {
          APP_URL = "https://health.altanen.casa";
          AUTO_LOGIN = "admin@altanen.casa";
        };
      };

      agent = {
        enable = true;

        environment = {
          LISTEN = "127.0.0.1:45876";
          KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJshyKXyMb9W1xxPZfS9rUU1XcqTaG7MGPqchuUq7aBD";
          INTEL_GPU_DEVICE = "drm:/dev/dri/card0";
        };

        smartmon.enable = true;
      };
    };

    systemd.services.beszel-agent = {
      path = [ pkgs.intel-gpu-tools ];
      serviceConfig = {
        SupplementaryGroups = [
          "video"
          "render"
        ];
        AmbientCapabilities = [
          "CAP_PERFMON"
          "CAP_SYS_ADMIN"
          "CAP_SYS_RAWIO"
        ];
        CapabilityBoundingSet = [
          "CAP_PERFMON"
          "CAP_SYS_ADMIN"
          "CAP_SYS_RAWIO"
        ];
        SystemCallFilter = [
          "@system-service"
          "perf_event_open"
        ];
      };
    };

    boot.kernel.sysctl = {
      "kernel.perf_event_paranoid" = 2;
    };

    services.nginx.virtualHosts."health.altanen.casa" = {
      useACMEHost = "altanen.casa";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8090";
        proxyWebsockets = true;
      };
    };
  };

  flake.modules.nixos.beszel-agent = {
    services.beszel.agent = {
      enable = true;

      environment = {
        LISTEN = "0.0.0.0:45876";
        KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJshyKXyMb9W1xxPZfS9rUU1XcqTaG7MGPqchuUq7aBD";
        GPU_COLLECTOR = "amd_sysfs";
      };

      smartmon.enable = true;
    };

    networking.firewall.allowedTCPPorts = [ 45876 ];
  };
}
