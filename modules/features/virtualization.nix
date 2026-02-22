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
      programs.virt-manager.enable = true;

      users.users.julius = {
        extraGroups = ["libvirtd"];
      };
    };
  };
}
