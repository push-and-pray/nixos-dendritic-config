{ inputs, ... }: {
  flake.modules.nixos.qbittorrent =
    let
      vpnInterface = "wg0";
      vpnPublicKey = "Vwqy4HMGPvkGaZXyYTNFUBJ8M5Qyo+d/ia+J4Np3Azk=";
      vpnEndpoint = "149.88.109.34:51820";
      vpnAddress = "10.2.0.2/32";
      vpnDNS = "10.2.0.1";
    in
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      port-forward = pkgs.callPackage ../../../pkgs/port-forward.nix { };
      setWebUIPassword = "${pkgs.python3}/bin/python3 ${./qbittorrent-webui-password.py} ${
        config.sops.secrets."qbittorrent/password".path
      } /var/lib/qBittorrent/qBittorrent/config/qBittorrent.conf";

      vpnConfinement = {
        NetworkNamespacePath = "/run/netns/vpn";
        TemporaryFileSystem = [ "/run/systemd/resolve:ro" ];
        BindReadOnlyPaths = [ "/etc/netns/vpn/resolv.conf:/run/systemd/resolve/stub-resolv.conf" ];
        InaccessiblePaths = [ "/run/nscd/socket" ];
      };
    in
    {
      imports = with inputs.self.modules.nixos; [
        media-group
      ];

      environment.systemPackages = [ pkgs.wireguard-tools ];

      environment.etc."netns/vpn/resolv.conf".text = "nameserver ${vpnDNS}\n";

      services.nginx.virtualHosts."qbittorrent.altanen.casa" = {
        useACMEHost = "altanen.casa";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true;
        };
      };

      sops.secrets = {
        wg = {
          sopsFile = ../../../secrets/wg.yaml;
          mode = "0400";
          restartUnits = [ "netns-vpn.service" ];
        };
        "qbittorrent/password" = {
          sopsFile = ../../../secrets/qbittorrent.yaml;
          path = "/run/secrets/qbittorrent-password";
          group = "media";
          mode = "0440";
        };
      };

      services.qbittorrent = {
        enable = true;
        group = "media";
        extraArgs = [ "--confirm-legal-notice" ];
        serverConfig = {
          Network.PortForwardingEnabled = false;
          Core.AutoDeleteAddedTorrentFile = "IfAdded";
          Preferences = {
            WebUI = {
              Address = "127.0.0.1";
              Username = "admin";
              MaxAuthenticationFailCount = 10;
              BanDuration = 300;
            };
            General.Locale = "en";
          };
          BitTorrent.Session = {
            Interface = vpnInterface;
            InterfaceName = vpnInterface;
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

      systemd = {
        tmpfiles.rules = [
          "d /media/downloads 0770 qbittorrent media -"
          "d /var/lib/qBittorrent 0770 qbittorrent media -"
          "Z /var/lib/qBittorrent 0770 qbittorrent media -"
        ];
        sockets.qbittorrent-webui = {
          description = "qBittorrent WebUI proxy socket";
          wantedBy = [ "sockets.target" ];
          socketConfig.ListenStream = "127.0.0.1:8080";
        };
        services = {
          netns-vpn = {
            description = "WireGuard VPN Network Namespace";
            before = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            path = [
              pkgs.iproute2
              pkgs.wireguard-tools
            ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = pkgs.writeShellScript "netns-vpn-up" ''
                set -euo pipefail

                ip netns add vpn 2>/dev/null || true
                ip -n vpn link set lo up

                ip -n vpn link del ${vpnInterface} 2>/dev/null || true
                ip link del ${vpnInterface} 2>/dev/null || true

                ip link add ${vpnInterface} type wireguard
                ip link set ${vpnInterface} netns vpn
                ip -n vpn addr add ${vpnAddress} dev ${vpnInterface}

                ip netns exec vpn wg set ${vpnInterface} \
                  private-key ${config.sops.secrets.wg.path} \
                  peer ${vpnPublicKey} \
                  endpoint ${vpnEndpoint} \
                  allowed-ips 0.0.0.0/0 \
                  persistent-keepalive 25

                ip -n vpn link set ${vpnInterface} up
                ip -n vpn route add default dev ${vpnInterface}
              '';
              ExecStop = pkgs.writeShellScript "netns-vpn-down" ''
                ip -n vpn link del ${vpnInterface} 2>/dev/null || true
                ip netns del vpn 2>/dev/null || true
              '';
            };
          };
          qbittorrent = {
            bindsTo = [ "netns-vpn.service" ];
            after = [ "netns-vpn.service" ];
            serviceConfig = vpnConfinement // {
              UMask = "0002";
              ExecStartPre = lib.mkAfter [ setWebUIPassword ];
            };
          };
          qbittorrent-webui = {
            description = "qBittorrent WebUI proxy into VPN namespace";
            bindsTo = [
              "qbittorrent.service"
              "qbittorrent-webui.socket"
            ];
            after = [
              "qbittorrent.service"
              "qbittorrent-webui.socket"
            ];
            serviceConfig = {
              Type = "notify";
              NetworkNamespacePath = "/run/netns/vpn";
              ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:8080";
              PrivateTmp = true;
              DynamicUser = true;
            };
          };
          portforward = {
            description = "NAT-PMP port forwarder for qBittorrent";
            bindsTo = [ "qbittorrent.service" ];
            partOf = [ "qbittorrent.service" ];
            after = [ "qbittorrent.service" ];
            wantedBy = [ "qbittorrent.service" ];

            serviceConfig = vpnConfinement // {
              ExecStart = "${port-forward}/bin/portforward";
              Restart = "on-failure";
              RestartSec = "10s";
              PrivateTmp = true;
              User = "qbittorrent";
            };
          };
        };
      };
    };
}
