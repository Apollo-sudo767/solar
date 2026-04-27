{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.shell.shell;
  host = config.networking.hostName;
in
{
  options.myFeatures.core.shell.shell.enable = lib.mkEnableOption "Apollo's Zsh & Starship Setup";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.eza
      pkgs.fzf
      pkgs.starship
    ];

    programs.zsh.enable = true;

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (name: {
      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          add_newline = false;
          format = "$directory$git_branch$character";

          # Clean Gruvbox Directory
          directory = {
            style = "bold fg:214"; # Gruvbox Orange
            truncation_length = 3;
            fish_style_pwd_dir_length = 1;
          };

          # Git Branch with the icon you were using
          git_branch = {
            symbol = " ";
            style = "bold fg:142"; # Gruvbox Green
          };

          # Character symbols (➜)
          character = {
            success_symbol = "[➜](bold fg:108)"; # Gruvbox Aqua
            error_symbol = "[➜](bold fg:167)"; # Gruvbox Red
          };

          # Fixed Palette (Underscores only, no hyphens)
          palette = lib.mkForce "gruvbox_dark";
          palettes.gruvbox_dark = {
            black = "#282828";
            bright_black = "#928374";
            red = "#cc241d";
            bright_red = "#fb4934";
            green = "#98971a";
            bright_green = "#b8bb26";
            yellow = "#d79921";
            bright_yellow = "#fabd2f";
            blue = "#458588";
            bright_blue = "#83a598";
            magenta = "#b16286";
            bright_magenta = "#d3869b";
            cyan = "#689d6a";
            bright_cyan = "#8ec07c";
            white = "#a89984";
            bright_white = "#ebdbb2";
            orange = "#d65d0e";
            bright_orange = "#fe8019";
          };
        };
      };

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        shellAliases = {
          # The Seeding Command: RAM-only, vanishes on reboot
          seed = "export BW_SESSION=$(bw unlock --raw) && mkdir -p /run/user/$(id -u)/sops && bw get item 'Solar Age Master' | jq -r '.notes' > /run/user/$(id -u)/sops/keys.txt && chmod 600 /run/user/$(id -u)/sops/keys.txt";
          unseed = "rm -f /run/user/$(id -u)/sops/keys.txt && echo 'Solar Master Key purged from RAM.'";
          ls = "eza --icons --ignore-glob='LICENSE*|README*|flake.lock|.git'";
          ll = "ls -l";
          la = "eza -a";
          # Use your host variable for easy rebuilds
          nrs = "sudo nixos-rebuild switch --flake .#${host}";
          nrb = "sudo nixos-rebuild boot --flake .#${host}";
          drs = "sudo darwin-rebuild switch --flake .#${host}";
          nfu = "nix flake update";
          nfc = "nix flake check";
          gs = "git status";
          ga = "git add";
          gc = "git commit";
          v = "hx"; # Short for Helix
          ff = "fastfetch";
        };

        initContent = ''
          # Ensure Starship initializes correctly
          eval "$(starship init zsh)"

          # General Shell Prefs
          export EDITOR=helix
          # ... the rest of your init code
        '';
      };
    });
  };
}
