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
        description = "Optional legacy edition selector.";
      };

      platform = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "windows"
            "android"
            "both"
          ]
        );
        default = null;
        description = "Optional legacy platform selector alias.";
      };
    };
  };

  config = lib.mkMerge [
    # Top-level minecraft.enable defaults to enabling Java Edition
    (lib.mkIf cfg.enable {
      myFeatures.programs.media.minecraft.java.enable = lib.mkDefault true;
    })

    # Legacy edition / platform fallback mapping
    (lib.mkIf (cfg.bedrock.enable || cfg.bedrock.edition != null || cfg.bedrock.platform != null) {
      myFeatures.programs.media.minecraft.bedrock = {
        windows.enable = lib.mkIf (
          (cfg.bedrock.edition or null) == "windows"
          || (cfg.bedrock.edition or null) == "both"
          || (cfg.bedrock.platform or null) == "windows"
          || (cfg.bedrock.platform or null) == "both"
          || (
            cfg.bedrock.enable
            && (cfg.bedrock.edition or null) == null
            && (cfg.bedrock.platform or null) == null
          )
        ) (lib.mkDefault true);

        android.enable = lib.mkIf (
          (cfg.bedrock.edition or null) == "android"
          || (cfg.bedrock.edition or null) == "both"
          || (cfg.bedrock.platform or null) == "android"
          || (cfg.bedrock.platform or null) == "both"
        ) (lib.mkDefault true);
      };
    })
  ];
}
