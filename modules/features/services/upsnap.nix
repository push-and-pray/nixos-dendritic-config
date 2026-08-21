{
  flake.modules.nixos.upsnap = {
    virtualisation = {
      oci-containers = {
        backend = "podman";

        containers.upsnap = {
          image = "ghcr.io/seriousm4x/upsnap:5.2.8";

          volumes = [
            "/var/lib/upsnap/pb_data:/app/pb_data"
          ];

          environment = {
            TZ = "Europe/Copenhagen";
            UPSNAP_SCAN_RANGE = "192.168.0.0/24";
            UPSNAP_INTERVAL = "*/3 * * * * *";
            UPSNAP_WEBSITE_TITLE = "UpSnap";
          };

          extraOptions = [
            "--network=host"
            "--cap-add=NET_RAW"
          ];
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/upsnap/pb_data 0750 root root -"
    ];
  };
}
