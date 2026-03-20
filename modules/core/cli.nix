{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.core.cli;
  # Grab the hostname of the current machine for the rebuild aliases
  host = config.networking.hostName;
in
{
  options.myFeatures.core.cli = {
    enable = lib.mkEnableOption "Standard CLI tools, Zsh, and System Aliases";
  };

  config = lib.mkIf cfg.enable {
    # --- SYSTEM LEVEL ---
    environment.systemPackages = with pkgs; [
      git
      helix
      btop
      eza
      fzf
      fd
      ripgrep
      starship # Added starship for a better prompt
    ];

    programs.zsh.enable = true;

    # --- USER LEVEL (Home Manager) ---
    home-manager.users = lib.mapAttrs (name: _: {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        shellAliases = {
          # --- File Management (The Clean Terminal) ---
          ls = "eza --icons --ignore-glob='LICENSE*|README*|flake.lock|.git'";
          ll = "ls -l";
          la = "eza -a";
          
          # --- Nix Flake Commands ---
          nfc = "nix flake check";
          nfu = "nix flake update";

          # --- NixOS Rebuild Commands (Context Aware) ---
          nrs = "sudo nixos-rebuild switch --flake .#${host}";
          nrb = "sudo nixos-rebuild boot --flake .#${host}";
          
          # --- Git Shorthands ---
          gs = "git status";
          ga = "git add";
          gc = "git commit";
        };

        # Initialize Starship Prompt
        initExtra = ''
          eval "$(starship init zsh)"
          export EDITOR="vim"
        '';
      };
    }) config.myFeatures.users;
  };
}
