{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.development;
in
{
  options.myFeatures.suites.development = {
    enable = lib.mkEnableOption "Advanced Development Suite (Helix, Git, Direnv, Nix-LD, Antigravity, Fastfetch)";
  };

  config = lib.mkIf cfg.enable {
    myFeatures.programs.terminal = {
      helix.enable = lib.mkDefault true;
      git.enable = lib.mkDefault true;
      direnv.enable = lib.mkDefault true;
      nix-ld.enable = lib.mkDefault true;
      antigravity.enable = lib.mkDefault true;
      fastfetch.enable = lib.mkDefault true;
      nh.enable = lib.mkDefault true;
    };
  };
}
