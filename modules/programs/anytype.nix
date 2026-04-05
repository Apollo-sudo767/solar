{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.programs.anytype;
in
{
  # --- OPTIONS ---
  options.myFeatures.programs.anytype = {
    enable = lib.mkEnableOption "Anytype - Local-first, P2P personal knowledge base";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.anytype;
      description = "The Anytype package to use.";
    };

    # Example of a custom toggle for the sync server if you were self-hosting
    # but for now, we focus on the desktop client.
  };

  # --- CONFIG ---
  config = lib.mkIf cfg.enable {
    # Install the anytype package system-wide
    environment.systemPackages = [
      cfg.package
    ];

    # Anytype is an unfree package, so we ensure it's allowed if this module is on
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "anytype"
    ];

    # Optional: Persistence or specific environment variables could be added here
    # per the Solar "Nix-Way" refactor standards.
  };
}
