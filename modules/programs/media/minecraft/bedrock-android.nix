# modules/programs/media/minecraft/bedrock-android.nix
# ============================================================================
# Minecraft: Bedrock Edition (Android / MCPELauncher via Flatpak)
# ============================================================================
# Installs `io.mrarm.mcpelauncher` declaratively via nix-flatpak and provides
# `mcpelauncher` / `mcpelauncher-ui-qt` CLI wrappers. State persistence under
# `~/.var` is handled globally by `modules/services/system/flatpak.nix`.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.minecraft.bedrock.android;
in
{
  options.myFeatures.programs.media.minecraft.bedrock.android = {
    enable = lib.mkEnableOption "Minecraft Bedrock for Android (MCPELauncher via Flatpak)";
  };

  config = lib.mkIf cfg.enable {
    # Ensure Flatpak support is active (which also preserves ~/.var)
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
  };
}
