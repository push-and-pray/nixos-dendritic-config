{ inputs, ... }: {
  flake.modules.nixos.qbittorrent =
    let
      vpnInterface = "wg0";
      vpnPublicKey = "Vwqy4HMGPvkGaZXyYTNFUBJ8M5Qyo+d/ia+J4Np3Azk=";
      vpnEndpoint = "149.88.109.34:51820";
      vpnAddress = "10.2.0.2/32";
      vpnDNS = "10.2.0.1";
    in
    { config, ... }: {
      imports = with inputs.self.modules.nixos; [
        media-group
      ];

      networking.useNetworkd = true;
      networking.firewall.allowedTCPPorts = [ 8080 ];

      sops.secrets = {
        wg = {
          sopsFile = ../../../secrets/wg.yaml;
          group = "systemd-network";
          mode = "0440";
          restartUnits = [ "systemd-networkd.service" ];
        };
        "qbittorrent/password" = {
          sopsFile = ../../../secrets/qbittorrent.yaml;
          group = "media";
          mode = "0440";
        };
      };

      systemd = {
        tmpfiles.rules = [
          "d /media/downloads 0770 root media -"
          "d /var/lib/qBittorrent 0770 root media -"
        ];

        network.netdevs."50-${vpnInterface}" = {
          netdevConfig = {
            Kind = "wireguard";
            Name = vpnInterface;
          };
          wireguardConfig = {
            PrivateKeyFile = config.sops.secrets.wg.path;
          };
          wireguardPeers = [
            {
              PublicKey = vpnPublicKey;
              AllowedIPs = [ "0.0.0.0/0" ];
              Endpoint = vpnEndpoint;
              PersistentKeepalive = 25;
            }
          ];
        };

        services."container@qbittorrent".after = [ "systemd-networkd.service" ];
      };

      containers.qbittorrent = {
        autoStart = true;
        privateNetwork = true;
        ephemeral = true;

        bindMounts = {
          "/media/downloads" = {
            hostPath = "/media/downloads";
            isReadOnly = false;
          };
          "/var/lib/qBittorrent" = {
            hostPath = "/var/lib/qBittorrent";
            isReadOnly = false;
          };
          "/run/secrets/qbittorrent-password" = {
            hostPath = config.sops.secrets."qbittorrent/password".path;
            isReadOnly = true;
          };
        };

        hostAddress = "192.168.100.1";
        localAddress = "192.168.100.2";

        forwardPorts = [
          {
            containerPort = 8080;
            hostPort = 8080;
            protocol = "tcp";
          }
        ];

        interfaces = [ vpnInterface ];

        config =
          { lib, pkgs, ... }:
          let
            port-forward = pkgs.python3Packages.callPackage ../../../pkgs/port-forward.nix { };
            setWebUIPassword = "${pkgs.python3}/bin/python3 ${./qbittorrent-webui-password.py} /run/secrets/qbittorrent-password /var/lib/qBittorrent/qBittorrent/config/qBittorrent.conf";
          in
          {
            imports = [ inputs.self.modules.nixos.media-group ];

            system.stateVersion = "26.05";
            environment.systemPackages = [ pkgs.wireguard-tools ];

            networking = {
              firewall.allowedTCPPorts = [ 8080 ];
              firewall.trustedInterfaces = [ vpnInterface ];
              useNetworkd = true;
              useHostResolvConf = false;
              nameservers = [ vpnDNS ];
            };

            systemd = {
              network = {
                networks."50-${vpnInterface}" = {
                  matchConfig.Name = vpnInterface;
                  address = [ vpnAddress ];
                  dns = [ vpnDNS ];
                  routes = [
                    {
                      Destination = "0.0.0.0/0";
                      Metric = 50;
                    }
                  ];
                };

                networks."40-eth0" = {
                  matchConfig.Name = "eth0";
                  address = [ "192.168.100.2/24" ];
                  routes = [
                    {
                      Destination = "192.168.0.0/24";
                      Gateway = "192.168.100.1";
                    }
                  ];
                };
              };
            };
            services.qbittorrent = {
              enable = true;
              group = "media";
              serverConfig = {
                Networking = {
                  PortForwardingEnabled = false;
                };
                Core = {
                  AutoDeleteAddedTorrentFile = "IfAdded";
                };
                Application = {
                };
                Preferences = {
                  WebUI = {
                    Address = "192.168.100.2";
                    Username = "admin";

                    MaxAuthenticationFailCount = 10;
                    BanDuration = 300;
                  };
                  General.Locale = "en";
                };
                BitTorrent = {
                  Session = {
                    DefaultSavePath = "/media/downloads";
                    BTProtocol = "TCP";
                    GlobalMaxInactiveSeedingMinutes = 1440;
                    GlobalMaxRatio = 2;
                    IgnoreSlowTorrentsForQueueing = true;
                    DisableAutoTMMByDefault = false;
                    DisableAutoTMMTriggers = {
                      CategorySavePathChanged = false;
                      DefaultSavePathChanged = false;
                    };
                  };
                };
              };
            };

            systemd.services.qbittorrent.serviceConfig = {
              UMask = "0002";

              ExecStartPre = lib.mkAfter [ setWebUIPassword ];
            };

            systemd.services.portforward = {
              bindsTo = [ "qbittorrent.service" ];
              after = [
                "qbittorrent.service"
                "network-online.target"
              ];
              wantedBy = [ "multi-user.target" ];
              wants = [ "network-online.target" ];

              serviceConfig = {
                ExecStart = "${port-forward}/bin/portforward";
                Restart = "on-failure";
                RestartSec = "10s";
                PrivateTmp = true;
                DynamicUser = true;
                SupplementaryGroups = [ "media" ];
              };
            };
          };
      };
    };
}
