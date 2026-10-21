# modules/core/nix/lix.nix
# ============================================================================
# Lix Package Manager Engine (`pkgs.lix`)
# ============================================================================
# Replaces the standard C++ Nix daemon with Lix (a modern, high-reliability
# fork of Nix) and strips the `mimalloc` meson flag to avoid allocator build
# issues on certain platforms.
{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.nix.lix;
in
{
  options.myFeatures.core.nix.lix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use the Lix package manager implementation instead of standard Nix.";
    };
  };

  config = lib.mkIf (cfg.enable && isTotal) {
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
