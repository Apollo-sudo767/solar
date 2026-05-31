{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.logseq;
in
{
  options.myFeatures.programs.utilities.logseq.enable = lib.mkEnableOption "Logseq";

  config = lib.mkIf cfg.enable {
    # On Darwin, we usually use Homebrew for GUI apps like Logseq
    # unless we want to use the Nix version.
    environment.systemPackages = lib.optional (!isDarwin) pkgs.logseq;
  };
}
