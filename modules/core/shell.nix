{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.core.shell;
  host = config.networking.hostName;
in
{
  options.myFeatures.core.shell.enable = lib.mkEnableOption "Apollo's Zsh & P10k Setup";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.zsh-powerlevel10k ];
    programs.zsh.enable = true;

    home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        # CHANGE THIS LINE:
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" "z" "sudo" "colored-man-pages" "extract" "history-substring-search" ];
        };

        shellAliases = {
          ls = "eza --icons --ignore-glob='LICENSE*|README*|flake.lock|.git'";
          ll = "ls -l";
          la = "eza -a";
          nrs = "sudo nixos-rebuild switch --flake .#${host}";
          nrb = "sudo nixos-rebuild boot --flake .#${host}";
          nfu = "nix flake update";
          nfc = "nix flake check";
          gs = "git status";
          ga = "git add";
          gc = "git commit";
        };

        initContent = ''
          export EDITOR=helix
          export PATH="$HOME/.local/bin:$PATH"
          setopt HIST_IGNORE_ALL_DUPS
          setopt SHARE_HISTORY
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        '';
      };
    });
  };
}
