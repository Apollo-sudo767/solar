{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.styling.skyNoctalia;
  inherit (config.myFeatures.core.system.users) usernames;
  iconFile = ../../../assets/icons/Apollo.jpg;
in
{
  options.myFeatures.platforms.styling.skyNoctalia.enable =
    lib.mkEnableOption "Apollo's Sky Noctalia v5 Rice";

  config = lib.mkIf cfg.enable {
    myFeatures.platforms.addons.noctalia-v5.enable = true;

    home-manager.users = lib.genAttrs usernames (_name: {
      programs.noctalia = {
        settings = {
          # v5 Specific Configuration
          bar = {
            enable = true;
            position = "top";
            height = 36;
            barType = "simple";
            density = "default";
            showOutline = false;
            showCapsule = true;
            capsuleOpacity = 1.0;
            capsuleColorKey = "none";
            widgetSpacing = 6;
            contentPadding = 2;
            fontScale = 1;
            enableExclusionZoneInset = true;
            backgroundOpacity = 1.0;
            useSeparateOpacity = false;
            marginVertical = 4;
            marginHorizontal = 4;
            frameThickness = 8;
            frameRadius = 12;
            outerCorners = true;
            hideOnOverview = false;
            displayMode = "always_visible";

            widgets = {
              left = [
                {
                  id = "Launcher";
                  icon = "rocket";
                  useDistroLogo = false;
                }
                {
                  id = "Clock";
                  formatHorizontal = "HH:mm ddd, MMM dd";
                }
                {
                  id = "SystemMonitor";
                  compactMode = true;
                  showCpuTemp = true;
                  showCpuUsage = true;
                  showMemoryUsage = true;
                }
                {
                  id = "ActiveWindow";
                  maxWidth = 145;
                }
              ];
              center = [
                {
                  id = "Workspace";
                  labelMode = "index";
                  showBadge = true;
                  showLabelsOnlyWhenOccupied = true;
                }
              ];
              right = [
                {
                  id = "Tray";
                  drawerEnabled = true;
                }
                {
                  id = "NotificationHistory";
                  showUnreadBadge = true;
                }
                {
                  id = "Battery";
                  displayMode = "graphic-clean";
                }
                {
                  id = "Volume";
                  displayMode = "onhover";
                }
                {
                  id = "Brightness";
                  displayMode = "onhover";
                }
                {
                  id = "ControlCenter";
                  icon = "noctalia";
                }
              ];
            };
          };

          # Hardcoded Sky Theme Colors (v5)
          # Specifically requested to be defined here.
          colors = {
            mPrimary = "#2471a3";
            mOnPrimary = "#050a18";
            mSecondary = "#ff9f43";
            mOnSecondary = "#050a18";
            mSurface = "#050a18";
            mOnSurface = "#abb2bf";
            mBackground = "#050a18";
            mOnBackground = "#abb2bf";
            mOutline = "#101f3b";
          };

          general = {
            avatarImage = iconFile;
            animationSpeed = 1;
            enableShadows = true;
            enableBlurBehind = false;
            radiusRatio = 1;
            screenRadiusRatio = 1;
          };

          appLauncher = {
            sortByMostUsed = true;
            iconMode = "tabler";
            showCategories = true;
            position = "center";
          };

          controlCenter = {
            position = "close_to_bar_button";
            shortcuts = {
              left = [
                { id = "Network"; }
                { id = "Bluetooth"; }
                { id = "WallpaperSelector"; }
              ];
              right = [
                { id = "Notifications"; }
                { id = "PowerProfile"; }
                { id = "KeepAwake"; }
              ];
            };
          };
        };
      };
    });
  };
}


