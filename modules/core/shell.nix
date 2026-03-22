{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.core.shell;
  host = config.networking.hostName;
in
{
  options.myFeatures.core.shell.enable = lib.mkEnableOption "Apollo's Zsh & P10k Setup";

  config = lib.mkIf cfg.enable {
    # Install system-wide zsh and the p10k theme
    environment.systemPackages = [ 
      pkgs.zsh-powerlevel10k 
      pkgs.eza 
      pkgs.fzf
    ];
    
    programs.zsh.enable = true;

    home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        # Correct Home Manager attribute name
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" "z" "sudo" "colored-man-pages" "extract" "history-substring-search" ];
          theme = "robbyrussell"; 
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
          
          # Source p10k theme from the nix store path
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        '';
      };
    });
  };
}
