{
  description = "idleberg's nix-config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager, }:
    let
      configuration = { pkgs, config, ... }: {
        nixpkgs.config.allowUnfree = true;
        environment.systemPackages = [
          pkgs.act
          pkgs.atuin
          pkgs.bat
          pkgs.corepack
          pkgs.curl
          pkgs.deno
          pkgs.eza
          pkgs.fish
          pkgs.fnm
          pkgs.fzf
          pkgs.git
          pkgs.git-lfs
          pkgs.git-crypt
          # pkgs.ghostty
          pkgs.glow
          pkgs.go
          pkgs.goreleaser
          pkgs.hyperfine
          pkgs.macchina
          pkgs.maestral
          pkgs.mkalias
          pkgs.mkcert
          pkgs.nixfmt
          pkgs.nodejs
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
            # Browsers
            "arc"
            "firefox@developer-edition"
            "google-chrome"
            "google-chrome@dev"

            # Development
            "gb-studio"
            "ghostty" # nix package is broken
            "idleberg/tap/krampus"
            "orbstack"
            "playdate-simulator"
            "postman"
            "sequel-ace"
            "visual-studio-code"
            "zed"

            # Gaming
            "fs-uae"
            "gog-galaxy"
            "openemu"
            "scummvm"
            "steam"

            # Quicklook Plugins
            "qlmarkdown"
            "quicklook-json"
            "webpquicklook"

            # Audio
            "ableton-live-standard@11"
            "airfoil"
            "audacity"
            "focusrite-control"
            "freac"

            # Other
            "grandperspective"
            "iina"
            "imageoptim"
            "handbrake"
            "linearmouse"
            "little-snitch"
            "kap"
            "keka"
            "maccy"
            "obs"
            "rar"
            "signal"
            "spotify"
            "transmission"
            "tunnelblick"
            "virtualbuddy"
            "wine-stable"
            "xquartz"
          ];

          # Applications installed from the Mac App Store (MAS)
          # masApps = {
          #   "1Password" = 1333542190;
          #   "Alfred" = 405843582;
          #   "iA Writer" = 775737590;
          #   "LocalSend" = 1661733229;
          #   "Microsoft Remote Desktop" = 1295203466;
          #   "PiBar" = 1514292645;
          #   "The Archive Browser" = 510232205;
          #   "System Color Picker" = 1545870783;
          #   "Transmit" = 1436522307;
          #   "Xcode" = 497799835;
          # };

          onActivation.cleanup = "zap";
          onActivation.autoUpdate = true;
          onActivation.upgrade = true;
        };

        fonts.packages = [ pkgs.departure-mono pkgs.fira pkgs.ibm-plex ];

        system.primaryUser = "jan";

        networking.computerName = "minerva";
        time.timeZone = "Europe/Vienna";

        system.defaults = {
          controlcenter.Bluetooth = true;
          controlcenter.Sound = true;
          finder.AppleShowAllExtensions = true;
          finder.FXPreferredViewStyle = "Nlsv";
          finder.ShowHardDrivesOnDesktop = true;
          finder.ShowMountedServersOnDesktop = true;
          finder.ShowStatusBar = true;
          finder.ShowPathbar = true;
          menuExtraClock.Show24Hour = true;
          menuExtraClock.ShowSeconds = true;
          screencapture.location = "/Users/jan/Desktop/Screenshots";
          loginwindow.GuestEnabled = false;

          NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
        };

        system.defaults.CustomUserPreferences = {
          "com.apple.finder" = {
            ShowExternalHardDrivesOnDesktop = true;
            ShowHardDrivesOnDesktop = false;
            ShowMountedServersOnDesktop = false;
            ShowRemovableMediaOnDesktop = true;
            _FXSortFoldersFirst = false;
            # When performing a search, search the current folder by default
            FXDefaultSearchScope = "SCcf";
            NewWindowTargetPath = "file://\${HOME}/Desktop/";
            FXEnableExtensionChangeWarning = false;
          };
          "com.apple.desktopservices" = {
            # Avoid creating .DS_Store files on network or USB volumes
            DSDontWriteNetworkStores = true;
            DSDontWriteUSBStores = true;
          };
          "com.apple.ActivityMonitor" = {
            OpenMainWindow = true;
            IconType = 5;
            SortColumn = "CPUUsage";
            SortDirection = 0;
          };
          "com.apple.SoftwareUpdate" = {
            AutomaticCheckEnabled = true;
            # Check for software updates daily, not just once per week
            ScheduleFrequency = 1;
            # Download newly available updates in background
            AutomaticDownload = 1;
            # Install System data files & security updates
            CriticalUpdateInstall = 1;
          };
        };

        # Add ability to used TouchID for sudo authentication
        security.pam.services.sudo_local.touchIdAuth = true;

        system.defaults.dock = {
          autohide = true;
          mineffect = "scale";
          show-recents = false;
          tilesize = 36;
          largesize = 64;
          magnification = true;
          wvous-br-corner = 4; # "Show Desktop;

          persistent-apps = [
            "/Applications/Google Chrome.app"
            "/Applications/Visual Studio Code.app"
            "/Applications/Mail.app"
            "/Applications/Messages.app"
            "/Applications/Music.app"
            "/Applications/Spotify.app"
            "/Applications/System Settings.app"
            "/Applications/Nix Apps/Ghostty.app"
            "/Applications/Nix Apps/Warp.app"
            "/Applications/Signal.app"
            "/Applications/Nix Apps/Obsidian.app"
          ];
        };

        # Make Nix applications available in Spotlight
        system.activationScripts.applications.text = let
          env = pkgs.buildEnv {
            name = "system-applications";
            paths = config.environment.systemPackages;
            pathsToLink = "/Applications";
          };
        in pkgs.lib.mkForce ''
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

        # programs.home-manager.enable = true;

        # programs.bat.enable = true;
        # programs.bat.config.theme = "Nord";

        # programs.git = {
        #   enable = true;
        #   userEmail = "git@idleberg.com";
        #   userName = "Jan T. Sott";
        #   diff-so-fancy.enable = true;
        #   lfs.enable = true;
        # };

        # # Enable alternative shell support in nix-darwin.
        # programs.fish = {
        #   enable = true;
        #   shellAliases = {
        #     # System
        #     ".." = "cd ..";
        #     "ls" = "eza";
        #     "ll" = "eza -la";

        #     # Shortcuts
        #     "desk" = "cd ~/Desktop";
        #     "dl" = "cd ~/Downloads";
        #     "mr" = "cd ~/Repositories";

        #     # Typos
        #     "gti" = "git";
        #     "gitp" = "git";
        #   };
        # };

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 6;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
      };
    in {
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
