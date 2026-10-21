# modules/programs/media/minecraft/common.nix
# ============================================================================
# Minecraft Suite Router
# ============================================================================
# Top-level router for `myFeatures.programs.media.minecraft`:
# - `minecraft.enable = true` defaults to enabling Java Edition (`java.nix`).
# - `minecraft.bedrock.enable = true` routes to `bedrock.windows` ("windows",
#   the default), `bedrock.android` ("android"), or both ("both") based on
#   `minecraft.bedrock.edition`.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.programs.media.minecraft;
in
{
  options.myFeatures.programs.media.minecraft = {
    enable = lib.mkEnableOption "Minecraft Suite";

    bedrock = {
      enable = lib.mkEnableOption "Minecraft Bedrock Edition";

      edition = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "windows"
            "android"
            "both"
          ]
        );
        default = null;
        description = "Bedrock runtime selector: 'windows' (BedrockOnLinux), 'android' (MCPELauncher), or 'both'.";
      };
    };
  };

  config = lib.mkMerge [
    # Top-level minecraft.enable defaults to enabling Java Edition
    (lib.mkIf cfg.enable {
      myFeatures.programs.media.minecraft.java.enable = lib.mkDefault true;
    })

    # Route bedrock.enable / bedrock.edition to the respective Bedrock backends
    (lib.mkIf (cfg.bedrock.enable || cfg.bedrock.edition != null) {
      myFeatures.programs.media.minecraft.bedrock = {
        windows.enable = lib.mkIf (
          cfg.bedrock.edition == "windows"
          || cfg.bedrock.edition == "both"
          || (cfg.bedrock.enable && cfg.bedrock.edition == null)
        ) (lib.mkDefault true);

        android.enable = lib.mkIf (cfg.bedrock.edition == "android" || cfg.bedrock.edition == "both") (
          lib.mkDefault true
        );
      };
    })
  ];
}
