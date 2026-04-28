{
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

{
  options.myFeatures.core.system.fonts = {
    enable = lib.mkEnableOption "Core System Fonts";
  };

  config = lib.mkIf isTotal (
    lib.mkMerge [
      # Universal Fonts (Loaded on both Mac and Linux)
      {
        fonts.packages = with pkgs; [
          nerd-fonts.jetbrains-mono
          nerd-fonts.fira-code
        ];
      }

      # Linux-Only Fonts Configuration
      (lib.optionalAttrs (!isDarwin) {
        fonts.enableDefaultPackages = true;
      })
    ]
  );
}
