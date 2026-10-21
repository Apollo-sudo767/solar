# modules/hardware/system/graphics.nix
# ============================================================================
# Universal Graphics Acceleration (Mesa, Vulkan, VA-API & 32-bit Support)
# ============================================================================
# Enabled automatically by `amd.nix`, `intel.nix`, and `nvidia.nix`.
# Configures 64-bit and 32-bit OpenGL/Vulkan/VA-API libraries (required by
# Wayland compositors, Steam/Proton, and hardware video decoding).
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.hardware.system.graphics;
in
{
  options.myFeatures.hardware.system.graphics.enable =
    lib.mkEnableOption "Universal Graphics Acceleration";

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true; # Required for 32-bit games (Steam / Proton / Source engine)

      extraPackages = with pkgs; [
        # Vulkan Core Stack
        vulkan-loader
        vulkan-headers
        vulkan-tools
        vulkan-validation-layers

        # Mesa & VA-API/VDPAU Video Acceleration
        mesa
        libva
        libvdpau-va-gl
      ];

      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
        mesa
      ];
    };

    # Default session type hint for Wayland applications
    environment.variables = {
      XDG_SESSION_TYPE = "wayland";
    };
  };
}
