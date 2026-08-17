{ inputs, ... }: {
  flake.modules.nixos.wsl = {
    imports = [
      inputs.nixos-wsl.nixosModules.default
    ];

    wsl.enable = true;
    wsl.defaultUser = "julius";

    # Avoid cgroup collision with other WSL distros (e.g. podman-machine-default)
    # that share UID 1000 by using a NixOS-specific slice path.
    systemd.services."user@".serviceConfig.Slice = "user-nixos-%i.slice";
  };
}
