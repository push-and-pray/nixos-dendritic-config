{
  flake.modules.nixos.reverse-proxy = { config, ... }: {
    users.users.nginx.extraGroups = [ "acme" ];

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    security.acme = {
      acceptTerms = true;
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;

      virtualHosts."_" = {
        default = true;
        useACMEHost = "altanen.casa";
        forceSSL = true;
        locations."/" = {
          return = "404 \"404 Not Found\n\"";
          extraConfig = ''
            default_type text/plain;
          '';
        };
      };
    };

    sops.secrets = {
      cloudflare = {
        sopsFile = ../../secrets/cloudflare.yaml;
      };
    };

    sops.templates = {
      "cloudflare.env" = {
        path = "/run/secrets/cloudflare.env";
        content = ''
          CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."cloudflare"}
        '';
      };
    };

    security.acme.certs."altanen.casa" = {
      domain = "altanen.casa";
      extraDomainNames = [ "*.altanen.casa" ];
      dnsProvider = "cloudflare";
      environmentFile = "/run/secrets/cloudflare.env";
    };
  };
}
