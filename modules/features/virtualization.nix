{
  flake.modules.nixos = {
    libvirt = {pkgs, ...}: {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu;
          swtpm.enable = true;
        };
      };

      virtualisation.spiceUSBRedirection.enable = true;
      programs.virt-manager.enable = true;

      users.users.julius = {
        extraGroups = ["libvirtd"];
      };

      home-manager.sharedModules = [
        {
          home.packages = with pkgs; [
            remmina
          ];
        }
      ];
    };
  };
}
