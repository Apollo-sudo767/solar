{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:
let
  cfg = config.myFeatures.programs.terminal.nix-ld;
in
{
  options.myFeatures.programs.terminal.nix-ld.enable =
    lib.mkEnableOption "nix-ld helper for running unpatched binaries";

  config = lib.mkIf cfg.enable (
    lib.optionalAttrs (!isDarwin) {
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc
          zlib
          glib
          xorg.libX11
        ];
      };
    }
  );
}
