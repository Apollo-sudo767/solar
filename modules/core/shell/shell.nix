{
  config,
  lib,
  pkgs,
  inputs ? null,
  isTotal,
  ...
}:

let
  inherit isTotal;
  cfg = config.myFeatures.core.shell.shell;
  host = config.networking.hostName;
  secretsOverride =
    let
      secretsPath =
        if pkgs.stdenv.hostPlatform.isDarwin then
          "/Users/${config.myFeatures.core.system.users.mainUser}/src/solar-secrets"
        else
          "/home/${config.myFeatures.core.system.users.mainUser}/src/solar-secrets";
      hasLocalSecretsDir = builtins.pathExists secretsPath;
      rekeyedFallback =
        if inputs != null && (inputs ? self) then
          "${inputs.self}/rekeyed/${host}"
        else
          "$HOME/src/solar/rekeyed/${host}";
    in
    if
      (config.myFeatures.core.security.agenix.enable or false)
      && (config.myFeatures.core.security.agenix.usePrivateSecrets or false)
      && hasLocalSecretsDir
    then
      " --override-input solar-secrets path:${secretsPath}"
    else
      " --override-input solar-secrets path:${rekeyedFallback}";
in
{
  options.myFeatures.core.shell.shell.enable = lib.mkEnableOption "Apollo's Zsh & Starship Setup";

  config = lib.mkIf cfg.enable {
    environment.enableAllTerminfo = true;

    environment.systemPackages = [
      pkgs.eza
      pkgs.fzf
    ];

    programs.zsh.enable = true;

    environment.shellAliases = {
      nrs = "nh os switch -Q";
      nrb = "nh os boot -Q";
      drs = "nh darwin switch -Q";
      nfu = "nix flake update";
      nfc = "nix flake check";
    };

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      programs.starship = {
        enable = true;
        package = pkgs.starship;
        enableZshIntegration = true;
        settings = {
          add_newline = false;
          format = "$directory$git_branch$character";

          # Clean Gruvbox Directory
          directory = {
            style = lib.mkDefault "bold fg:214"; # Gruvbox Orange
            truncation_length = 3;
            fish_style_pwd_dir_length = 1;
          };

          # Git Branch with the icon you were using
          git_branch = {
            symbol = " ";
            style = lib.mkDefault "bold fg:142"; # Gruvbox Green
          };

          # Character symbols (➜)
          character = {
            success_symbol = lib.mkDefault "[➜](bold fg:108)"; # Gruvbox Aqua
            error_symbol = lib.mkDefault "[➜](bold fg:167)"; # Gruvbox Red
          };

          # Fixed Palette (Underscores only, no hyphens)
          # palette = lib.mkDefault "gruvbox_dark"; # Stylix will handle this
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
          # Use nh for clean, non-noisy progress bars
          nrs = "nh os switch -Q";
          nrb = "nh os boot -Q";
          drs = "nh darwin switch -Q";
          nfu = "nix flake update";
          nfc = "nix flake check";
          gs = "git status";
          ga = "git add";
          gc = "git commit";
          v = "hx"; # Short for Helix
          ff = "fastfetch --config examples/24.jsonc";
        };

        initContent = ''
          # General Shell Prefs
          export EDITOR=hx
          export DIRENV_LOG_FORMAT="" # Quiet direnv chatter
        '';
      };
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && !pkgs.stdenv.hostPlatform.isDarwin)
        {
          files = lib.concatMap (name: [
            "/home/${name}/.zsh_history"
          ]) config.myFeatures.core.system.users.usernames;
        };
  };
}
