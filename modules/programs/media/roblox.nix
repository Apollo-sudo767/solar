# modules/programs/media/roblox.nix
# ============================================================================
# Roblox (Sober via Flatpak)
# ============================================================================
# Installs Sober (`org.vinegarhq.Sober`) declaratively via nix-flatpak and
# provides a `sober` CLI launcher wrapper. State persistence under `~/.var` is
# handled globally by `modules/services/system/flatpak.nix`.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.roblox;
in
{
  options.myFeatures.programs.media.roblox = {
    enable = lib.mkEnableOption "Roblox Suite (Sober via Flatpak)";
  };

  config = lib.mkIf cfg.enable {
    # Ensure Flatpak support is enabled (which also preserves ~/.var)
    myFeatures.services.system.flatpak.enable = lib.mkDefault true;

    # Declarative package installation via nix-flatpak
    services.flatpak.packages = [
      "org.vinegarhq.Sober"
    ];

    # Convenience CLI launcher wrapper
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "sober" ''
        exec flatpak run org.vinegarhq.Sober "$@"
      '')
    ];
  };
}
