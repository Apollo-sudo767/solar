# modules/programs/terminal/nix-ld.nix
#
# Configures `nix-ld` on NixOS to support running unpatched dynamically
# linked binaries while keeping the option cross-platform safe.
{
  config,
  lib,
  pkgs,
  isDarwin,
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
          libX11
        ];
      };
    }
  );
}
