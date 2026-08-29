{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:
let
  cfg = config.myFeatures.programs.terminal.nh;
  flakePath = "${config.myFeatures.core.system.users.mainHome}/src/solar";
in
{
  options.myFeatures.programs.terminal.nh.enable = lib.mkEnableOption "nh (Nix Helper) integration";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        programs.nh = {
          enable = true;
          # Automatically clean generations older than 7 days, keeping the last 5
          clean = {
            enable = true;
            extraArgs = "--keep-since 7d --keep 5";
          };
          # Points nh to your primary flake directory for easier rebuilds
          flake = flakePath;
        };

        # Disable default Nix GC to avoid conflict warning with nh clean
        nix.gc.automatic = lib.mkForce false;
      })
      (lib.optionalAttrs isDarwin {
        environment.systemPackages = [ pkgs.nh ];
        environment.variables.NH_FLAKE = flakePath;
      })
    ]
  );
}
