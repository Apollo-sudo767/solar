# modules/core/shell/shell.nix
# ============================================================================
# Interactive Zsh & Starship Prompt Configuration
# ============================================================================
# Configures Zsh as the interactive user shell across NixOS and macOS:
# - Enables `cli.nix` by default so `eza`, `fzf`, and `helix` are always present.
# - Sets `NH_FLAKE` to the user's Solar checkout (`~/src/solar`) so `nh` commands
#   work from any working directory.
# - Configures the Starship prompt with a clean minimal format (`$directory$git_branch$character`)
#   and Gruvbox fallback colors (overridden automatically when Stylix is enabled).
# - Defines system-wide rebuild/cleanup aliases (`nrs`, `nrb`, `drs`, `nc`, etc.)
#   and user-level Zsh completion, syntax highlighting, history, and git/eza aliases.
{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.shell.shell;
in
{
  options.myFeatures.core.shell.shell.enable = lib.mkEnableOption "Apollo's Zsh & Starship Setup";

  config = lib.mkIf (cfg.enable && isTotal) {
    # Ensure core CLI utilities (`eza`, `fzf`, `helix`, etc.) are available
    myFeatures.core.shell.cli.enable = lib.mkDefault true;

    environment.enableAllTerminfo = true;
    programs.zsh.enable = true;

    # Point `nh` to the local Solar flake repository automatically
    environment.variables = {
      NH_FLAKE =
        if pkgs.stdenv.hostPlatform.isDarwin then
          "/Users/${config.myFeatures.core.system.users.mainUser}/src/solar"
        else
          "/home/${config.myFeatures.core.system.users.mainUser}/src/solar";
    };

    # System-wide Nix & `nh` helper aliases (automatically inherited by all shells)
    environment.shellAliases = {
      nrs = "nh os switch --no-nom";
      nrb = "nh os boot --no-nom";
      drs = "nh darwin switch --no-nom";
      nfu = "nix flake update";
      nfc = "nix flake check";
      nc = "nh clean all --keep 5 --keep-since 7d";
      ncl = "nh clean all --keep 5 --keep-since 7d";
      nco = "nh clean all --keep 5 --keep-since 7d --optimise";
    };

    # Per-user Starship prompt & interactive Zsh configuration via Home Manager
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      programs.starship = {
        enable = true;
        package = pkgs.starship;
        enableZshIntegration = true;
        settings = {
          add_newline = false;
          format = "$directory$git_branch$character";

          directory = {
            style = lib.mkDefault "bold fg:214"; # Gruvbox Orange
            truncation_length = 3;
            fish_style_pwd_dir_length = 1;
          };

          git_branch = {
            symbol = " ";
            style = lib.mkDefault "bold fg:142"; # Gruvbox Green
          };

          character = {
            success_symbol = lib.mkDefault "[➜](bold fg:108)"; # Gruvbox Aqua
            error_symbol = lib.mkDefault "[➜](bold fg:167)"; # Gruvbox Red
          };

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

        history = {
          size = 10000;
          save = 10000;
          path = "$HOME/.local/state/zsh/history";
          share = true;
        };

        # User-level productivity aliases (system rebuild aliases come from `environment.shellAliases`)
        shellAliases = {
          ls = "eza --icons --ignore-glob='LICENSE*|README*|flake.lock|.git'";
          ll = "ls -l";
          la = "eza -a";
          gs = "git status";
          ga = "git add";
          gc = "git commit";
          v = "hx"; # Helix modal editor
          ff = "fastfetch --config examples/24.jsonc";
        };

        initContent = ''
          # General Shell Preferences
          export EDITOR=hx
          export DIRENV_LOG_FORMAT="" # Quiet direnv log output
        '';
      };
    });
  };
}
