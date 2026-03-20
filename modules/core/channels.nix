{ config, lib, inputs, pkgs, ... }:

let
  cfg = config.myFeatures.core.channels;
in
{
  options.myFeatures.core.channels = {
    useStable = lib.mkOption {
      type = lib.types.bool;
      default = false; # Default to Unstable (Rolling)
      description = "If true, the system uses nixpkgs-stable as the primary source.";
    };
  };

  config = {
    # This magic line swaps the 'pkgs' variable for the entire system
    nixpkgs.pkgs = let
      channel = if cfg.useStable then inputs.nixpkgs-stable else inputs.nixpkgs-unstable;
    in import channel {
      inherit (pkgs) system;
      config.allowUnfree = true;
    };
  };
}
