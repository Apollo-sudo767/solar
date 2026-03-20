{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.gruvboxniri;
in
{
  options.myFeatures.gruvboxniri = {
    enable = lib.mkEnableOption "The Gruvbox Niri Desktop Suite";
  };

  config = lib.mkIf cfg.enable {
    # This single switch now flips all these other switches:
    myFeatures = {
      desktop.niri.enable = true;
      themes.gruvbox.enable = true;
      terminal.foot.enable = true;
      browser.zen.enable = true;
      gaming.enable = true;
    };

    # You can also add suite-specific packages here
    environment.systemPackages = [ pkgs.gruvbox-plus-icon-pack ];
  };
}
