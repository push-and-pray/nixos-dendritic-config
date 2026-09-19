{ inputs, ... }: {
  flake.modules.nixos.server =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = with inputs.self.modules.nixos; [
        nix
        locale
        systemd-boot
        ssh
        tailscale
        sops
      ];

      nixpkgs.hostPlatform = "x86_64-linux";

      boot.loader.systemd-boot.bootCounting.enable = true;

      security.sudo.wheelNeedsPassword = false;
      users.users.julius = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIL27EDkViSsAa6PByx7ZaqAg2CgL3V1Wiy6RmQ/StegbAAAABHNzaDo= julius@zeus"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPiaayaWR+KgD/2gUke5ll5ZKHMLnTJx/3bfc2522qiQ julius@ares"
        ];
      };

      services.openssh.settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };

      services.tailscale = {
        authKeyFile = config.sops.secrets.tailscale-auth-key.path;
        openFirewall = true;
      };

      sops.secrets.tailscale-auth-key = {
        sopsFile = ../../secrets/ts-key.yaml;
        key = lib.mkDefault "ts-key";
      };

      environment = {
        enableAllTerminfo = true;
        systemPackages = [ pkgs.neovim ];
      };
    };
}
