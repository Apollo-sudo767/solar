{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.systems.gnome;
in
{
  options.myFeatures.systems.gnome = {
    enable = lib.mkEnableOption "GNOME Desktop Environment";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.desktopManager.gnome.enable = true;     
    # Exclude bloat to keep the system lean
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      epiphany 
    ];
  };
}
