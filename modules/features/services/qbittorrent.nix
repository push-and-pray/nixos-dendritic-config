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
      port-forward = pkgs.python3Packages.callPackage ../../../pkgs/port-forward.nix { };
      setWebUIPassword = "${pkgs.python3}/bin/python3 ${./qbittorrent-webui-password.py} ${
        config.sops.secrets."qbittorrent/password".path
      } /var/lib/qBittorrent/qBittorrent/config/qBittorrent.conf";
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
          proxyPass = "http://192.168.100.2:8080";
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
        serverConfig = {
          Network.PortForwardingEnabled = false;
          Core.AutoDeleteAddedTorrentFile = "IfAdded";
          Preferences = {
            WebUI = {
              Address = "192.168.100.2";
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
        network.networks."40-ve-vpn" = {
          matchConfig.Name = "ve-vpn";
          linkConfig.Unmanaged = true;
        };
        services = {
          netns-vpn = {
            description = "WireGuard VPN Network Namespace";
            before = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = pkgs.writeShellScript "netns-vpn-up" ''
                set -euo pipefail

                ${pkgs.iproute2}/bin/ip netns add vpn 2>/dev/null || true
                ${pkgs.iproute2}/bin/ip -n vpn link set lo up

                ${pkgs.iproute2}/bin/ip -n vpn link del ${vpnInterface} 2>/dev/null || true
                ${pkgs.iproute2}/bin/ip link del ${vpnInterface} 2>/dev/null || true
                ${pkgs.iproute2}/bin/ip link del ve-vpn 2>/dev/null || true

                ${pkgs.iproute2}/bin/ip link add ${vpnInterface} type wireguard
                ${pkgs.iproute2}/bin/ip link set ${vpnInterface} netns vpn
                ${pkgs.iproute2}/bin/ip -n vpn addr add ${vpnAddress} dev ${vpnInterface}

                ${pkgs.iproute2}/bin/ip netns exec vpn ${pkgs.wireguard-tools}/bin/wg set ${vpnInterface} \
                  private-key ${config.sops.secrets.wg.path} \
                  peer ${vpnPublicKey} \
                  endpoint ${vpnEndpoint} \
                  allowed-ips 0.0.0.0/0 \
                  persistent-keepalive 25

                ${pkgs.iproute2}/bin/ip -n vpn link set ${vpnInterface} up
                ${pkgs.iproute2}/bin/ip -n vpn route add default dev ${vpnInterface}

                ${pkgs.iproute2}/bin/ip link add ve-vpn type veth peer name veth-vpn
                ${pkgs.iproute2}/bin/ip link set veth-vpn netns vpn

                ${pkgs.iproute2}/bin/ip addr add 192.168.100.1/24 dev ve-vpn
                ${pkgs.iproute2}/bin/ip link set ve-vpn up

                ${pkgs.iproute2}/bin/ip -n vpn addr add 192.168.100.2/24 dev veth-vpn
                ${pkgs.iproute2}/bin/ip -n vpn link set veth-vpn up
              '';
              ExecStop = pkgs.writeShellScript "netns-vpn-down" ''
                ${pkgs.iproute2}/bin/ip -n vpn link del ${vpnInterface} 2>/dev/null || true
                ${pkgs.iproute2}/bin/ip link del ve-vpn 2>/dev/null || true
                ${pkgs.iproute2}/bin/ip netns del vpn 2>/dev/null || true
              '';
            };
          };
          qbittorrent = {
            bindsTo = [ "netns-vpn.service" ];
            after = [ "netns-vpn.service" ];
            serviceConfig = {
              UMask = "0002";
              ExecStartPre = lib.mkAfter [ setWebUIPassword ];

              NetworkNamespacePath = "/run/netns/vpn";
              BindReadOnlyPaths = [ "/etc/netns/vpn/resolv.conf:/etc/resolv.conf" ];
              InaccessiblePaths = [
                "/run/nscd/socket"
                "/run/systemd/resolve/io.systemd.Resolve"
              ];
            };
          };
          portforward = {
            bindsTo = [ "qbittorrent.service" ];
            after = [ "qbittorrent.service" ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
              NetworkNamespacePath = "/run/netns/vpn";
              BindReadOnlyPaths = [ "/etc/netns/vpn/resolv.conf:/etc/resolv.conf" ];
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
