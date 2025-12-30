{inputs, ...}: {
  flake.modules.homeManager = {
    cli = {
      imports = with inputs.self.modules.homeManager; [
        devops
        utils
        nixvim
        git
        direnv
        nix-index
      ];
    };

    nix-index = {
      imports = [
        inputs.nix-index-database.homeModules.nix-index
      ];
      programs.nix-index-database.comma.enable = true;
      programs.nix-index.enable = true;
    };

    devops = {pkgs, ...}: {
      home.packages = with pkgs; [
        kubectl
        kubelogin-oidc
        kubeseal
        fluxcd
        teleport
        k9s
      ];
    };
    utils = {pkgs, ...}: {
      home.packages = with pkgs; [
        curl
        wget
        dig
      ];
    };
    nixvim = {pkgs, ...}: {
      home.packages = [
        inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
      home.sessionVariables = {
        EDITOR = "nvim";
        SUDO_EDITOR = "nvim";
      };
    };

    git = {
      programs.git = {
        enable = true;
        settings = {
          user = {
            email = "62392537+push-and-pray@users.noreply.github.com";
            name = "push-and-pray";
          };
          pull = {
            rebase = true;
          };
        };
      };
      programs.lazygit.enable = true;
    };

    direnv = {
      programs = {
        direnv = {
          enable = true;
          nix-direnv = {
            enable = true;
          };
        };
      };
    };
  };
}
