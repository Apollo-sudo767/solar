{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.core.fonts;
in
{
  options.myFeatures.core.fonts.enable = lib.mkEnableOption "Apollo's Font Stack & Emoji Fallbacks";

  config = lib.mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        jetbrains-mono
        nerd-fonts.jetbrains-mono
      ];

      fontconfig.defaultFonts = {
        serif = [ "Noto Serif" "Noto Color Emoji" ];
        sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
        monospace = [ "JetBrainsMono Nerd Font" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
