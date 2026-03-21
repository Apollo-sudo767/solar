{ config, lib, ... }:

let
  cfg = config.myFeatures.core.channels;
in
{
  options.myFeatures.core.channels = {
    # This is populated by the autoscanner (hosts/default.nix)
    isStable = lib.mkOption {
      type = lib.types.bool;
      default = false; 
      description = "Internal: Whether the host is using the stable branch.";
    };

    # Helper strings for stateVersion references
    stableVersion = lib.mkOption { 
      type = lib.types.str; 
      default = "25.11"; 
    };
    unstableVersion = lib.mkOption { 
      type = lib.types.str; 
      default = "26.05"; 
    };

    # This provides a clean way to get the version string anywhere in your config
    currentVersion = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = if cfg.isStable then cfg.stableVersion else cfg.unstableVersion;
    };
  };

  # DO NOT add a 'config = { ... }' block that sets nixpkgs.pkgs here.
  # That logic now lives safely in hosts/default.nix.
}
