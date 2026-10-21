# modules/programs/media/gaming.nix
# ============================================================================
# Media Gaming Toggle
# ============================================================================
# Convenience toggle under `myFeatures.programs.media.gaming` that enables the
# Steam gaming platform without implicitly forcing additional game launchers
# (such as Minecraft Java). For full gaming workstation setups, prefer
# `myFeatures.suites.gaming`.
{
  config,
  lib,
  ...
}:

{
  options.myFeatures.programs.media.gaming = {
    enable = lib.mkEnableOption "Gaming Media Platform (Steam)";
  };

  config = lib.mkIf config.myFeatures.programs.media.gaming.enable {
    myFeatures.programs.media.steam.enable = lib.mkDefault true;
  };
}
