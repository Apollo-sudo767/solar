{ config, lib, inputs, pkgs, ... }:

let
  cfg = config.myFeatures.core.channels;
  
  # Define your standard versions
  stableVersion = "25.05";
  unstableVersion = "25.11"; 
in
{
  options.myFeatures.core.channels = {
    useStable = lib.mkOption {
      type = lib.types.bool;
      default = false; # DEFAULT IS NOW UNSTABLE
      description = "If true, the system uses nixpkgs-stable. If false (default), it uses unstable.";
    };
    
    defaultState = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = if cfg.useStable then stableVersion else unstableVersion;
      description = "The recommended stateVersion based on the selected channel.";
    };
  };

  config = {
    # Apply the channel to the system
    nixpkgs.pkgs = let
      channel = if cfg.useStable then inputs.nixpkgs-stable else inputs.nixpkgs-unstable;
    in import channel {
      inherit (pkgs) system;
      config.allowUnfree = true;
    };

    # Set the SYSTEM stateVersion automatically
    system.stateVersion = cfg.defaultState;
  };
}
