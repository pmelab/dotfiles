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
          pkgs.ghostty
          # Dotfile managment
          pkgs.stow
          # Prompt and history
          pkgs.starship
          pkgs.fish
          pkgs.atuin
          # Automatically load .envrc files.
          pkgs.direnv
          # Best editor
          pkgs.helix
          # File manager 
          pkgs.yazi
          # Git stuff
          pkgs.lazygit
          pkgs.git
          # Required for nix configuration in nvim
          pkgs.nixfmt-classic
          pkgs.nil
          # Global node for global CLI tools
          pkgs.nodejs
          pkgs.phpactor
          # Markdown notetaking
          pkgs.marksman
          pkgs.obsidian
          pkgs.glow
          # Nice cli tools
          pkgs.bat
          pkgs.fd
          pkgs.gh
          pkgs.ripgrep
          pkgs.httpie
          pkgs.htop
          pkgs.eza
          pkgs.difftastic
        ];
        homebrew = {
          enable = true;

          onActivation = {
            autoUpdate = true;
            cleanup = "uninstall";
            upgrade = true;
          };
          taps = [ "uselagoon/lagoon-cli" ];
          brews = [ "lagoon" ];
          casks = [ "raycast" "mitmproxy" "firefox" "font-recursive-mono-nerd-font" "1password-cli" ];
        };

        # Auto upgrade nix package and the daemon service.
        services.nix-daemon.enable = true;
        # nix.package = pkgs.nix;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        programs.fish.enable = true;

        users.users.pmelab = { shell = pkgs.fish; };

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 4;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
        system.activationScripts.postUserActivation.text = ''
          # Following line should allow us to avoid a logout/login cycle
          /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
        '';
        system.defaults.dock.autohide = true;
        system.defaults.NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
        system.defaults.trackpad.TrackpadRightClick = true;
        
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
