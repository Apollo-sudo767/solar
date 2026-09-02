{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.mcpelauncher;
  flatpakCfg = config.myFeatures.services.system.flatpak.mcpelauncher;
  enabled = cfg.enable || (flatpakCfg.enable or false);
in
{
  options = {
    myFeatures.programs.media.mcpelauncher = {
      enable = lib.mkEnableOption "MCPELauncher (Minecraft Bedrock Edition) via Flatpak";
    };
    myFeatures.services.system.flatpak.mcpelauncher = {
      enable = lib.mkEnableOption "MCPELauncher (Minecraft Bedrock Edition) via Flatpak";
    };
  };

  config = lib.mkIf enabled {
    # Ensure Flatpak support is enabled
    myFeatures.services.system.flatpak.enable = lib.mkDefault true;

    # Declarative package installation via nix-flatpak
    services.flatpak.packages = [
      "io.mrarm.mcpelauncher"
    ];

    # Convenience CLI launcher wrappers
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
