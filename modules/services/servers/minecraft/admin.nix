{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.services.servers.minecraft.admin;
in
{
  options.myFeatures.services.servers.minecraft.admin.enable =
    lib.mkEnableOption "Minecraft Admin User and Directory Configuration";

  config = lib.mkIf cfg.enable {
    # Ensure mcadmin is included in the usernames list for home-manager and basic config
    myFeatures.core.system.users.usernames = [ "mcadmin" ];

    # Server User Configuration for friends
    users.users.mcadmin = {
      description = "Minecraft Server Admin";
      extraGroups = lib.mkForce [
        "minecraft"
        "networkmanager"
      ];
    };

    # Ensure /srv/minecraft is accessible to the mcadmin user via the minecraft group
    systemd.tmpfiles.rules = [
      "d /srv/minecraft 0775 minecraft minecraft - -"
    ];
  };
}
