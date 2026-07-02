{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.programs.terminal.git;
in
{
  options.myFeatures.programs.terminal.git = {
    enable = lib.mkEnableOption "Git Configuration";
    userName = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Git user name";
    };
    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Git user email";
    };
    users = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            userName = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Git user name override for this user";
            };
            userEmail = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Git user email override for this user";
            };
          };
        }
      );
      default = { };
      description = "Per-user git configuration overrides";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (name: {
      programs.git = {
        enable = true;
        settings = {
          user = {
            name =
              if (cfg.users ? ${name}) && (cfg.users.${name}.userName != null) then
                cfg.users.${name}.userName
              else
                cfg.userName;
            email =
              if (cfg.users ? ${name}) && (cfg.users.${name}.userEmail != null) then
                cfg.users.${name}.userEmail
              else
                cfg.userEmail;
          };
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
        };
      };
    });
  };
}
