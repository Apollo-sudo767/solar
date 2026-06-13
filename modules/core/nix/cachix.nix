{
  config,
  lib,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.nix.cachix;
in
{
  options.myFeatures.core.nix.cachix.enable = lib.mkEnableOption "Cachix binary caches";

  config = lib.mkIf cfg.enable {
    nix.settings = {
      substituters = [
        "https://niri.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "niri.cachix.org-1:Wv0Om607ZpInis2ExGh+4CKddPU1ot9dnG3v9L+N/X0="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
