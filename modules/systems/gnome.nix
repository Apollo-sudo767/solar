{ config, lib, pkgs, isDarwin, ... }: # <-- Add isDarwin

let
  cfg = config.myFeatures.systems.gnome;
in
{
  options.myFeatures.systems.gnome.enable = lib.mkEnableOption "GNOME Desktop Environment";

  # Shield everything
  config = lib.mkIf cfg.enable (lib.optionalAttrs (!isDarwin) {
    services.xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
    };
    
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      epiphany 
    ];
  });
}
