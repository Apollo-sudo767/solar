{ config, lib, pkgs, ... }:

{
  options.myFeatures.core.nix-settings.enable = lib.mkEnableOption "Core Nix flake and optimization settings";

  config = lib.mkIf config.myFeatures.core.nix-settings.enable {
    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
        warn-dirty = false;
        substituters = [ "https://niri.cachix.org" ];
        trusted-public-keys = [ "niri.cachix.org-1:Wv0Om607Z5KVzEDGyz69m0shV6vba6Kndf6966fS38Y=" ];
      };
      
      # Automatic Garbage Collection
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    programs.ssh.extraConfig = ''
    Host github.com
      IdentityFile /etc/ssh/ssh_host_ed25519_key
      User git
    '';

    # Allow unfree packages (like Nvidia drivers or Steam)
    nixpkgs.config.allowUnfree = true;
  };
}
