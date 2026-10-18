{
  config,
  lib,
  pkgs,
  isStable ? false,
  isTotal,
  ...
}:

let
  inherit isTotal;
  # 1. Setup a shortcut to your feature's config
  # Replace 'myFeature' with your actual feature name
  cfg = config.myFeatures.core.nix.lix;
in
{
  # --- OPTIONS ---
  # This defines the "switches" you flip in your /hosts files
  options.myFeatures.core.nix.lix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enables Lix in systems";
    };
  };

  # --- CONFIG ---
  # This is the "payload" that only runs if 'enable' is true
  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (_final: prev: {
        lix = prev.lix.overrideAttrs (old: {
          mesonFlags = builtins.filter (f: !(lib.strings.hasInfix "mimalloc" f)) (old.mesonFlags or [ ]);
        });
      })
    ];

    nix.package = lib.mkForce pkgs.lix;
  };
}
