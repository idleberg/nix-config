{
  description = "idleberg's Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {
          nixpkgs.config.allowUnfree = true;
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
            pkgs.glow
            pkgs.go
            pkgs.goreleaser
            pkgs.hyperfine
            pkgs.macchina
            pkgs.maestral
            pkgs.mkalias
            pkgs.mkcert
            pkgs.nixfmt
            pkgs.obsidian
            pkgs.oh-my-fish
            pkgs.p7zip
            pkgs.rar
            pkgs.scdl
            pkgs.sqlite
            pkgs.tealdeer
            pkgs.warp-terminal
            pkgs.yt-dlp
            pkgs.zoxide
          ];

          homebrew = {
            enable = true;
            brews = [
              "mas"

              # the NSIS package on the Nix repository is outdated and broken
              "nsis"
            ];
            casks = [
              "grandperspective"
              "iina"
              "fs-uae"
              "handbrake"
              "linearmouse"
              "keka"
              "maccy"
              "obs"
              "orbstack"
              "openemu"
              "playdate-simulator"
              "rar"
              "sequel-ace"
              "virtual-buddy"
              "visual-studio-code"
              "wine-stable"
              "xquartz"
              "zed"

              # Quicklook Plugins
              "qlmarkdown"
              "quicklook-json"
              "webpquicklook"
            ];
            masApps = {
              "1Password" = 1333542190;
              "Alfred" = 405843582;
              "iA Writer" = 775737590;
              "LocalSend" = 1661733229;
              "PiBar" = 1514292645;
              "The Archive Browser" = 510232205;
              "System Color Picker" = 1545870783;
              "Transmit" = 1436522307;
              "Xcode" = 497799835;
            };
            onActivation.cleanup = "zap";
            onActivation.autoUpdate = true;
            onActivation.upgrade = true;
          };

          fonts.packages = [
            pkgs.departure-mono
            pkgs.fira
            pkgs.ibm-plex
          ];

          system.primaryUser = "jan";

          system.defaults = {
            controlcenter.Bluetooth = true;
            controlcenter.Sound = true;
            dock.autohide = true;
            dock.mineffect = "scale";
            finder.AppleShowAllExtensions = true;
            finder.FXPreferredViewStyle = "Nlsv";
            finder.ShowHardDrivesOnDesktop = true;
            finder.ShowMountedServersOnDesktop = true;
            finder.ShowStatusBar = true;
            finder.ShowPathbar = true;
            menuExtraClock.Show24Hour = true;
            menuExtraClock.ShowSeconds = true;
            networking.computerName = "minerva";
            screencapture.location = "/Users/jan/Desktop/Screenshots";
            time.timeZone = "Europe/Vienna";
          };

          # Make Nix applications available in Spotlight
          system.activationScripts.applications.text =
            let
              env = pkgs.buildEnv {
                name = "system-applications";
                paths = config.environment.systemPackages;
                pathsToLink = "/Applications";
              };
            in
            pkgs.lib.mkForce ''
              rm -rf /Applications/Nix\ Apps
              mkdir -p /Applications/Nix\ Apps
              find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |

              while read -r src; do
                app_name=$(basename "$src")
                echo "copying $src" >&2
                ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
              done
            '';

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          programs.fish = {
            enable = true;
            shellAliases: {
              # System
              ".." = "cd ..";
              "ls" = "eza";
              "ll" = "eza -la";

              # Shortcuts
              "desk" = "cd ~/Desktop";
              "dl" = "cd ~/Downloads";
              "mr" = "cd ~/Repositories";

              # Typos
              "gti" = "git";
              "gitp" = "git"
            };
          };

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#minerva
      darwinConfigurations."minerva" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "jan";
            };
          }
        ];
        specialArgs = { inherit inputs; };
      };
    };
}
