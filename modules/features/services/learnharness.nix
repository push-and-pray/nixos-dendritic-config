{ inputs, ... }: {
  flake.modules.nixos.learnharness =
    { lib, pkgs, ... }:
    let
      port = 3010;
      domain = "learnharness.altanen.casa";
      pkg = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.learnharness;
    in
    {
      systemd.services.learnharness = {
        description = "LearnHarness adaptive learning web application";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        environment = {
          PORT = toString port;
          HOSTNAME = "127.0.0.1";
          CHROME_PATH = lib.getExe pkgs.chromium;
          HOME = "/var/lib/learnharness";
          LH_DATA_DIR = "/var/lib/learnharness/data";
          LH_AUTH_FILE = "/var/lib/learnharness/auth.json";
          LH_ALLOWED_HOSTS = domain;
        };

        serviceConfig = {
          ExecStart = lib.getExe pkg;
          DynamicUser = true;
          StateDirectory = "learnharness";
          WorkingDirectory = "/var/lib/learnharness";
          Restart = "on-failure";
          RestartSec = "5s";
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
        };
      };

      services.nginx.virtualHosts.${domain} = {
        useACMEHost = "altanen.casa";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          proxyWebsockets = true;
          extraConfig = ''
            client_max_body_size 30m;
            proxy_buffering off;
            proxy_read_timeout 10m;
            proxy_send_timeout 10m;
          '';
        };
      };
    };
}
