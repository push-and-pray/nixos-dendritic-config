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
        k9s
        kubernetes-helm
        inputs.self.packages.${pkgs.system}.bcvk
      ];
    };
    utils = {pkgs, ...}: {
      home.packages = with pkgs; [
        curl
        wget
        dig
        gemini-cli
        file
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

    git = {pkgs, ...}: let
      gls-script = pkgs.writeShellApplication {
        name = "git-gls";
        runtimeInputs = with pkgs; [git util-linux gawk];
        text = ''
          if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
            echo "Not a git repository."
            exit 1
          fi

          shopt -s dotglob

          {
            echo "NAME|LAST MODIFIED|MESSAGE"

            for file in *; do
              [ -e "$file" ] || continue

              [ "$file" = ".git" ] && continue

              if [ -d "$file" ]; then
                display_name="$file/"
              else
                display_name="$file"
              fi

              if git status --porcelain -- "$file" 2>/dev/null | grep -q "^"; then
                display_name="*$display_name"
              fi

              info=$(git log -1 --format="%ar|%s" -- "$file" 2>/dev/null)

              if [ -n "$info" ]; then
                echo "$display_name|$info"
              else
                echo "$display_name|-|*"
              fi
            done
          } | column -s "|" -t | awk 'NR==1{print "\033[1;4m" $0 "\033[0m"; next} {print}'
        '';
      };
    in {
      programs.git = {
        enable = true;

        settings = {
          alias = {
            ls = "!${gls-script}/bin/git-gls";
          };
          user = {
            email = "62392537+push-and-pray@users.noreply.github.com";
            name = "push-and-pray";
          };
          pull = {
            rebase = true;
          };
        };
      };

      home.packages = with pkgs; [
        git-extras
      ];
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
