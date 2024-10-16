{
  description = "idleberg's Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew
    }:
    let
      configuration = { pkgs, config, ... }: {

          nixpkgs.config.allowUnfree = true;

          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.act
            pkgs.atuin
            pkgs.bat
            pkgs.curl
            pkgs.deno
            pkgs.eza
            pkgs.fish
            pkgs.fnm
            pkgs.fzf
            pkgs.git
            pkgs.git-lfs
            pkgs.go
            pkgs.goreleaser
            pkgs.hyperfine
            pkgs.macchina
            pkgs.mkalias
            pkgs.nsis
            pkgs.obsidian
            pkgs.oh-my-fish
            pkgs.p7zip
            pkgs.rar
            pkgs.sqlite
            pkgs.tealdeer
            pkgs.warp-terminal
            pkgs.zoxide
          ];

          homebrew.packages = {
            enable = true;
            brews = [
              "mas"
            ];
            casks = [
              "grandperspective"
              "iina"
              "linearmouse"
              "orbstack"
              "qlmarkdown"
              "quicklook-json"
              "rar"
              "sequel-ace"
              "webpquicklook"
              "wine-stable"
              "xquartz"
            ];
            masApps = {
              "iA Writer" = 775737590;
              "LocalSend" = 1661733229;
              "PiBar" = 1514292645;
              "The Archive Browser" = 510232205;
              "Xcode" = 497799835;
            };
            onActivation.cleanup = "zap";
            onActivation.autoUpdate = true;
            onActivation.upgrade = true;
          };

          fonts.packages = [
            pkgs.fira
            pkgs.ibm-plex
          ];

          system.activationScripts.applications.text =
            let
              env = pkgs.buildEnv {
                name = "system-applications";
                paths = config.environment.systemPackages;
                pathsToLink = "/Applications";
              };
            in
            pkgs.lib.mkForce ''
              # Set up applications.
              echo "setting up /Applications..." >&2
              rm -rf /Applications/Nix\ Apps
              mkdir -p /Applications/Nix\ Apps
              find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
              while read src; do
                app_name=$(basename "$src")
                echo "copying $src" >&2
                ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
              done
            '';

          # see https://mynixos.com/
          system.defaults = {
            dock.autohide = true;
          };

          # Auto upgrade nix package and the daemon service.
          services.nix-daemon.enable = true;
          # nix.package = pkgs.nix;

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Create /etc/zshrc that loads the nix-darwin environment.
          # programs.zsh.enable = true;  # default shell on catalina
          programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 5;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };




    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."minerva" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "jan";
              autoMigrate = true;
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."minerva".pkgs;
    };
}
