{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.core.cli;
in
{
  options.myFeatures.core.cli.enable = lib.mkEnableOption "Standard CLI tools";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      git
      helix
      nixd
      btop
      eza
      fzf
      fd
      ripgrep
      wget
      curl
      sysstat
      lm_sensors
      fastfetch
      tree
      jq
    ];

    environment.variables.EDITOR = "hx";
    environment.variables.VISUAL = "hx";
  };
}
