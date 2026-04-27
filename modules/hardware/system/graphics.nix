{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.hardware.system.graphics;
in
{
  options.myFeatures.hardware.system.graphics.enable = lib.mkEnableOption "Universal Graphics Acceleration";

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true; # Essential for Steam / TF2
      
      extraPackages = with pkgs; [
        # Vulkan Core
        vulkan-loader
        vulkan-headers
        vulkan-tools
        vulkan-validation-layers
        
        # General Hardware Acceleration
        mesa
        libva
        libvdpau-va-gl
      ];

      extraPackages32 = with pkgs.pkgsi686Linux; [ 
        libva
        mesa 
      ];
    };

    # Basic environment for Wayland/Niri
    environment.variables = {
      # Help apps find the right drivers
      XDG_SESSION_TYPE = "wayland";
    };
  };
}
