{
  config,
  lib,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.logseq;
in
{
  config = lib.mkIf (cfg.enable && config.myFeatures.platforms.styling.stylix.enable) {
    home-manager.sharedModules = [
      {
        # Dynamically generate Logseq custom styling based on your Stylix palette
        home.file."${cfg.vaultPath}/logseq/custom.css".text =
          let
            colors = config.lib.stylix.colors.withHashtag;
          in
          ''
            /* Custom Stylix Theme Injection */
            :root {
              --ls-font-family: "${config.stylix.fonts.sansSerif.name}";
              --ls-font-mono-family: "${config.stylix.fonts.monospace.name}";

              --ls-primary-background-color: ${colors.base00};
              --ls-secondary-background-color: ${colors.base01};
              --ls-tertiary-background-color: ${colors.base02};

              --ls-primary-text-color: ${colors.base05};
              --ls-secondary-text-color: ${colors.base04};

              --ls-link-text-color: ${colors.base0D};
              --ls-link-text-hover-color: ${colors.base0E};

              --ls-border-color: ${colors.base02};
              --ls-guideline-color: ${colors.base02};

              --cl-head-initial: ${colors.base0A}; /* Headings */
              --ls-block-bullet-color: ${colors.base0C};
            }

            /* Clean, flat adjustments to match a minimal desktop environment */
            .cp__sidebar-left-container {
              background-color: var(--ls-secondary-background-color) !important;
            }
            a.tag {
              background-color: ${colors.base01} !important;
              color: ${colors.base0B} !important;
              border: 1px solid ${colors.base02} !important;
              border-radius: 4px;
              padding: 1px 6px;
            }
          '';
      }
    ];
  };
}
