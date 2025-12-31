{inputs, ...}: {
  flake.modules.nixos.stylix = {pkgs, ...}: {
    imports = [
      inputs.stylix.nixosModules.stylix
    ];

    stylix = {
      enable = true;
      image = ../../rsc/bg.png;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

      cursor = {
        package = pkgs.simp1e-cursors;
        name = "Simp1e-Gruvbox-Dark";
        size = 16;
      };

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font Mono";
        };
        serif = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
    home-manager.sharedModules = [
      ({
        config,
        lib,
        ...
      }: {
        stylix.targets.firefox.profileNames =
          lib.mkIf config.programs.firefox.enable ["default"];

        stylix.targets.hyprlock.enable =
          lib.mkIf config.programs.hyprlock.enable false;
      })
    ];
  };
}
