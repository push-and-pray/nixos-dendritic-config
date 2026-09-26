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
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJ6ff8lr573v+4rgXxwjqoV+ESDS8JHguN0p4RC4fZ0c5wd0u+sN+RSg/J8QpqNlDZqsvnikpk5QKAx57PD/G10= julius@zeus"
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBG9qewLarr7c1lAKviZQVvmqcQ5jmQbnFfcrQ+3mGODCEQoiha5oTFDMeUk4S3tpPIVBEg1c3rkNlkIYUMJ97cI= julius@ares"
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
