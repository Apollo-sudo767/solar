{
  config,
  lib,
  pkgs,
  inputs ? null,
  ...
}:

let
  cfg = config.myFeatures.programs.media.minecraft.bedrock.windows;
  aliasCfg = config.myFeatures.programs.media.minecraft.bedrock.bedrockOnLinux;
  topAliasCfg = config.myFeatures.programs.media.bedrockOnLinux;

  enabled = cfg.enable || (aliasCfg.enable or false) || (topAliasCfg.enable or false);

  bedrockOnLinuxFlakePkg =
    if
      inputs != null
      && inputs ? bedrock-on-linux
      && inputs.bedrock-on-linux ? packages
      && inputs.bedrock-on-linux.packages ? ${pkgs.stdenv.hostPlatform.system}
    then
      inputs.bedrock-on-linux.packages.${pkgs.stdenv.hostPlatform.system}.default
    else
      null;

  pkg =
    if cfg.package != null then
      cfg.package
    else if (aliasCfg.package or null) != null then
      aliasCfg.package
    else
      bedrockOnLinuxFlakePkg;
in
{
  options.myFeatures.programs.media.minecraft.bedrock = {
    windows = {
      enable = lib.mkEnableOption "Minecraft Bedrock for Windows (BedrockOnLinux)";
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = bedrockOnLinuxFlakePkg;
        description = "BedrockOnLinux package to install.";
      };
    };

    bedrockOnLinux = {
      enable = lib.mkEnableOption "BedrockOnLinux (alias for minecraft.bedrock.windows)";
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "BedrockOnLinux package to install.";
      };
    };
  };

  options.myFeatures.programs.media.bedrockOnLinux = {
    enable = lib.mkEnableOption "BedrockOnLinux (Minecraft Bedrock for Windows, alias for minecraft.bedrock.windows)";
  };

  config = lib.mkIf enabled {
    environment.systemPackages = lib.optionals (pkg != null) [
      pkg
      (pkgs.writeShellScriptBin "bedrockonlinux" ''
        exec ${lib.getExe pkg} "$@"
      '')
    ];

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf config.myFeatures.core.system.preservation.enable
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".local/share/bedrock-on-linux"
              ".config/bedrock-on-linux"
            ];
          });
        };
  };
}
