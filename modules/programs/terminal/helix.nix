{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  inherit isTotal;
  inherit (config.myFeatures.core.system.users) usernames;
in
{
  options.myFeatures.programs.terminal.helix.enable = lib.mkEnableOption "Helix Editor";

  config = lib.mkIf config.myFeatures.programs.terminal.helix.enable {

    # 1. Ensure the LSP and formatter binaries are actually installed on the system
    environment.systemPackages = with pkgs; [
      nixd
      nixfmt
    ];

    home-manager.users = lib.genAttrs usernames (_name: {
      programs.helix = {
        enable = true;

        # Define a custom theme using Stylix colors
        themes = lib.mkIf config.stylix.enable {
          stylix =
            let
              c = config.lib.stylix.colors;
            in
            {
              "ui.menu" = {
                fg = "base05";
                bg = "base01";
              };
              "ui.menu.selected" = {
                fg = "base01";
                bg = "base04";
              };
              "ui.linenr" = {
                fg = "base03";
              };
              "ui.popup" = {
                bg = "base01";
              };
              "ui.window" = {
                bg = "base01";
              };
              "ui.linenr.selected" = {
                fg = "base04";
              };
              "ui.selection" = {
                bg = "base02";
              };
              "ui.statusline" = {
                fg = "base04";
                bg = "base01";
              };
              "ui.statusline.inactive" = {
                fg = "base03";
                bg = "base01";
              };
              "ui.help" = {
                fg = "base06";
                bg = "base01";
              };
              "ui.cursor" = {
                fg = "base00";
                bg = "base05";
              };
              "ui.text" = "base05";
              "ui.text.focus" = "base05";
              "variable" = "base08";
              "constant" = "base09";
              "constant.numeric" = "base09";
              "comment" = "base03";
              "tag" = "base08";
              "attribute" = "base09";
              "type" = "base0A";
              "keyword" = "base0E";
              "function" = "base0D";
              "string" = "base0B";
              "constant.character.escape" = "base0C";
              "operator" = "base05";
              "special" = "base0C";
              "markup.heading" = "base0D";
              "markup.list" = "base08";
              "markup.bold" = {
                fg = "base0A";
                modifiers = [ "bold" ];
              };
              "markup.italic" = {
                fg = "base0E";
                modifiers = [ "italic" ];
              };
              "markup.link.url" = {
                fg = "base09";
                modifiers = [ "underline" ];
              };
              "markup.link.text" = "base08";
              "markup.quote" = "base0C";
              "markup.raw" = "base0B";
              "diff.plus" = "base0B";
              "diff.delta" = "base0A";
              "diff.minus" = "base08";

              # Palette mapping hex codes from Stylix
              palette = {
                base00 = "#${c.base00}";
                base01 = "#${c.base01}";
                base02 = "#${c.base02}";
                base03 = "#${c.base03}";
                base04 = "#${c.base04}";
                base05 = "#${c.base05}";
                base06 = "#${c.base06}";
                base07 = "#${c.base07}";
                base08 = "#${c.base08}";
                base09 = "#${c.base09}";
                base0A = "#${c.base0A}";
                base0B = "#${c.base0B}";
                base0C = "#${c.base0C}";
                base0D = "#${c.base0D}";
                base0E = "#${c.base0E}";
                base0F = "#${c.base0F}";
              };
            };
        };

        # Your existing settings
        settings = {
          theme = lib.mkIf config.stylix.enable "stylix";
          editor = {
            line-number = "relative";
            cursor-shape = {
              insert = "bar";
              normal = "block";
            };
          };
        };

        # 2. Wire up the Language Server
        languages = {
          language-server.nixd = {
            # lib.getExe safely points directly to the binary in the nix store
            command = lib.getExe pkgs.nixd;
          };

          language = [
            {
              name = "nix";
              auto-format = true;
              formatter.command = lib.getExe pkgs.nixfmt;
              language-servers = [ "nixd" ];
            }
          ];
        };

      };
    });
  };
}
