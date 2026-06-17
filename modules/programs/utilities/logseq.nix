{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.logseq;
in
{
  options.myFeatures.programs.utilities.logseq = {
    enable = lib.mkEnableOption "Logseq";
    vaultPath = lib.mkOption {
      type = lib.types.str;
      default = "Documents/Logseq";
      description = "The relative path to your Logseq vault from home directory.";
    };
  };

  config = lib.mkIf cfg.enable {
    # On Darwin, we usually use Homebrew for GUI apps like Logseq
    # unless we want to use the Nix version.
    environment.systemPackages = lib.optional (!pkgs.stdenv.isDarwin) pkgs.logseq;

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && !pkgs.stdenv.isDarwin)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/Logseq"
              cfg.vaultPath
            ];
          });
        };
  };
}
