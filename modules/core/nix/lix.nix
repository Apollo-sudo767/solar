{
  config,
  lib,
  pkgs,
  inputs,
  isTotal,
  ...
}:

let
  # 1. Setup a shortcut to your feature's config
  # Replace 'myFeature' with your actual feature name
  cfg = config.myFeatures.core.nix.lix;
in
{
  # --- OPTIONS ---
  # This defines the "switches" you flip in your /hosts files
  options.myFeatures.core.nix.lix = {
    enable = lib.mkEnableOption "Enables Lix in systems";
  };

  # --- CONFIG ---
  # This is the "payload" that only runs if 'enable' is true
  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        inherit (prev.lixPackageSets.stable)
          nixpkgs-review
          nix-eval-jobs
          nix-fast-build
          colmena
          ;
      })
    ];

    nix.package = pkgs.lixPackageSets.stable.lix;
  };
}
