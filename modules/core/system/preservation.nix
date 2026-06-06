{
  config,
  lib,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.core.system.preservation;
in
{
  options.myFeatures.core.system.preservation = {
    enable = lib.mkEnableOption "Wipe-on-Boot Preservation";
    persistentPath = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = "The root path for persistent storage.";
    };
  };

  config = lib.mkIf (cfg.enable && !isDarwin) {
    # Initialize the preservation config
    preservation = {
      enable = true;
      preserveAt."${cfg.persistentPath}" = {
        directories = [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
        ];
      };
    };
  };
}
