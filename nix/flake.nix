{
  description = "Philipp's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
    let
      configuration = { pkgs, ... }: {
        nixpkgs.config.allowUnfree = true;
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = [
          # Required for nix configuration in nvim
          pkgs.fish
          pkgs.nixfmt-classic
          pkgs.nil
          pkgs.phpactor
          # Python tools
          pkgs.python311
          pkgs.black
          pkgs.pyright
          pkgs.ruff-lsp
          pkgs.python311Packages.debugpy
        ];
        homebrew = {
          enable = true;
          onActivation = {
            autoUpdate = true;
            upgrade = true;
            cleanup = "zap";
          };
          taps = [ "uselagoon/lagoon-cli" ];
          brews = [
            # Editor
            "nvim"
            # Dotfile managment
            "stow"
            # Prompt and history
            "starship"
            "atuin"
            # Automatically load .envrc files.
            "direnv"
            # File manager 
            "yazi"
            # Git stuff
            "lazygit"
            "git"
            # Global node for global CLI tools
            "nodejs"
            # Markdown notetaking
            "marksman"
            "glow"
            # Nice cli tools
            "bat"
            "fd"
            "gh"
            "ripgrep"
            "httpie"
            "htop"
            "eza"
            "difftastic"
            "fzf"
            "zoxide"
            # Lagoon CLI
            "lagoon"
            "posting"
            "aider"
            "rainfrog"
          ];
          casks = [
            "font-recursive-mono-nerd-font"
            "raycast"
            "mitmproxy"
            "1password-cli"
            "1password"
            "ghostty"
            "obsidian"
            "zen-browser"
            "ollama"
          ];
          masApps = { Things = 904280696; };
        };

        # Auto upgrade nix package and the daemon service.
        # services.nix-daemon.enable = true;
        # nix.package = pkgs.nix;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        programs.fish.enable = true;

        environment.shells = [ pkgs.fish ];

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
        system.activationScripts.postUserActivation.text = ''
          # Following line should allow us to avoid a logout/login cycle
          /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
        '';
        system.defaults.dock.autohide = true;
        system.defaults.NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
        system.defaults.trackpad.TrackpadRightClick = true;
        system.defaults.trackpad.Clicking = true;

        system.defaults.NSGlobalDomain = {
          # `defaults read NSGlobalDomain "xxx"`
          "com.apple.swipescrolldirection" =
            true; # enable natural scrolling(default to true)
          "com.apple.sound.beep.feedback" =
            0; # disable beep sound when pressing volume up/down key
          AppleInterfaceStyle = "Dark"; # dark mode
          AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control.
          ApplePressAndHoldEnabled = false; # enable press and hold

          # If you press and hold certain keyboard keys when in a text area, the key’s character begins to repeat.
          # This is very useful for vim users, they use `hjkl` to move cursor.
          # sets how long it takes before it starts repeating.
          InitialKeyRepeat =
            15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
          # sets how fast it repeats once it starts. 
          KeyRepeat = 3; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)

          NSAutomaticCapitalizationEnabled =
            false; # disable auto capitalization(自动大写)
          NSAutomaticDashSubstitutionEnabled =
            false; # disable auto dash substitution(智能破折号替换)
          NSAutomaticPeriodSubstitutionEnabled =
            false; # disable auto period substitution(智能句号替换)
          NSAutomaticQuoteSubstitutionEnabled =
            false; # disable auto quote substitution(智能引号替换)
          NSAutomaticSpellingCorrectionEnabled =
            false; # disable auto spelling correction(自动拼写检查)
          NSNavPanelExpandedStateForSaveMode =
            true; # expand save panel by default(保存文件时的路径选择/文件名输入页)
          NSNavPanelExpandedStateForSaveMode2 = true;
        };

        system.keyboard = {
          enableKeyMapping =
            true; # enable key mapping so that we can use `option` as `control`

          # NOTE: do NOT support remap capslock to both control and escape at the same time
          remapCapsLockToControl =
            true; # remap caps lock to control, useful for emac users
          remapCapsLockToEscape =
            false; # remap caps lock to escape, useful for vim users

          # swap left command and left alt 
          # so it matches common keyboard layout: `ctrl | command | alt`
          #
          # disabled, caused only problems!
          swapLeftCommandAndLeftAlt = false;
        };

        # Sudo touch id auth
        security.pam.enableSudoTouchIdAuth = true;
      };
    in {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Philipps-MacBook-Pro
      darwinConfigurations."Philipps-MacBook-Pro" =
        nix-darwin.lib.darwinSystem { modules = [ configuration ]; };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Philipps-MacBook-Pro".pkgs;
    };
}
