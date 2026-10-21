# modules/programs/media/minecraft/bedrock-windows.nix
# ============================================================================
# Minecraft: Bedrock Edition (Windows GDK / BedrockOnLinux)
# ============================================================================
# Installs the native Windows GDK build of Minecraft Bedrock via the
# `bedrock-on-linux` flake input and preserves user worlds/configurations
# across ephemeral root reboots.
{
  config,
  lib,
  pkgs,
  inputs ? null,
  ...
}:

let
  cfg = config.myFeatures.programs.media.minecraft.bedrock.windows;

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
in
{
  options.myFeatures.programs.media.minecraft.bedrock.windows = {
    enable = lib.mkEnableOption "Minecraft Bedrock for Windows (BedrockOnLinux)";
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = bedrockOnLinuxFlakePkg;
      description = "BedrockOnLinux package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.optionals (cfg.package != null) [
      cfg.package
      (pkgs.writeShellScriptBin "bedrockonlinux" ''
        exec ${lib.getExe cfg.package} "$@"
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
