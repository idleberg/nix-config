{
  description = "idleberg's nix-config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nix-homebrew,
    home-manager,
  }: let
    configuration = {
      pkgs,
      config,
      ...
    }: {
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages = with pkgs; [
        # Development
        act
        corepack
        deno
        fnm
        git
        git-lfs
        git-crypt
        go
        goreleaser
        hyperfine
        mkcert
        nixfmt
        nodejs
        sqlite

        # Fancy new system tools
        atuin
        bat
        fzf
        eza
        zoxide

        # GUI tools
        maestral
        obsidian
        warp-terminal

        # Other
        curl
        fish
        # ghostty
        glow
        macchina
        mkalias
        oh-my-fish
        p7zip
        rar
        scdl
        starship
        tealdeer
        yt-dlp
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
          "orbstack"
          "playdate-simulator"
          "postman"
          "sequel-ace"
          "visual-studio-code"
          "zed"

          # Gaming
          "celeste-classic"
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
        masApps = {
          "1Password" = 1333542190;
          "Alfred" = 405843582;
          "iA Writer" = 775737590;
          "LocalSend" = 1661733229;
          "Microsoft Remote Desktop" = 1295203466;
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

      fonts.packages = with pkgs; [departure-mono fira ibm-plex nerd-fonts.blex-mono nerd-fonts.fira-mono];

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
        screencapture.location = "\${HOME}/Screenshots";
        loginwindow.GuestEnabled = false;

        NSGlobalDomain = {
          "com.apple.swipescrolldirection" = false;
          NSAutomaticSpellingCorrectionEnabled = false;
        };
      };

      # TODO decide when to use system.defaults vs system.defaults.CustomUserPreferences
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
        orientation = "right"; # TODO remove after testing

        persistent-apps = [
          "/Applications/Google Chrome.app"
          "/Applications/Visual Studio Code.app"
          "/Applications/Mail.app"
          "/Applications/Messages.app"
          "/Applications/Music.app"
          "/Applications/Spotify.app"
          "/Applications/System Settings.app"
          "/Applications/Ghostty.app"
          "/Applications/Nix Apps/Warp.app"
          "/Applications/Signal.app"
          "/Applications/Nix Apps/Obsidian.app"
        ];
      };

      # Make Nix applications available in Spotlight
      # TODO replace with https://github.com/hraban/mac-app-util
      system.activationScripts.applications.text = let
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

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in {
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
      specialArgs = {inherit inputs;};
    };
  };
}
