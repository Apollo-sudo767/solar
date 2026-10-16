{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.minecraft.bedrock.android;
  aliasCfg = config.myFeatures.programs.media.minecraft.bedrock.mcpelauncher;
  topAliasCfg = config.myFeatures.programs.media.mcpelauncher;
  flatpakMcpeCfg = config.myFeatures.services.system.flatpak.mcpelauncher;

  enabled =
    cfg.enable
    || (aliasCfg.enable or false)
    || (topAliasCfg.enable or false)
    || (flatpakMcpeCfg.enable or false);
in
{
  options.myFeatures.programs.media.minecraft.bedrock = {
    android = {
      enable = lib.mkEnableOption "Minecraft Bedrock for Android (MCPELauncher via Flatpak)";
    };
    mcpelauncher = {
      enable = lib.mkEnableOption "MCPELauncher (alias for minecraft.bedrock.android)";
    };
  };

  options.myFeatures.programs.media.mcpelauncher = {
    enable = lib.mkEnableOption "MCPELauncher (alias for minecraft.bedrock.android)";
  };

  options.myFeatures.services.system.flatpak.mcpelauncher = {
    enable = lib.mkEnableOption "MCPELauncher (Minecraft Bedrock Edition) via Flatpak";
  };

  config = lib.mkIf enabled {
    # Ensure Flatpak support is active
    myFeatures.services.system.flatpak.enable = lib.mkDefault true;

    # Declarative package installation via nix-flatpak
    services.flatpak.packages = [
      "io.mrarm.mcpelauncher"
    ];

    # CLI launcher wrappers
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "mcpelauncher" ''
        exec flatpak run io.mrarm.mcpelauncher "$@"
      '')
      (pkgs.writeShellScriptBin "mcpelauncher-ui-qt" ''
        exec flatpak run io.mrarm.mcpelauncher "$@"
      '')
    ];

    # State preservation for Minecraft Bedrock & MCPELauncher
    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf config.myFeatures.core.system.preservation.enable
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".var/app/io.mrarm.mcpelauncher"
            ];
          });
        };
  };
}
