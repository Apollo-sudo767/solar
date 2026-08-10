{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.ani-cli;

  fastanime = pkgs.python3Packages.buildPythonApplication {
    pname = "fastanime";
    version = "3.1.0";
    format = "pyproject";

    src = pkgs.fetchPypi {
      pname = "fastanime";
      version = "3.1.0";
      sha256 = "0nkdcsd6kgnzbpa6lflsh6q7lzxrb531bcfswpi4g6gqdim1v568";
    };

    nativeBuildInputs = with pkgs.python3Packages; [
      hatchling
    ];

    propagatedBuildInputs = with pkgs.python3Packages; [
      click
      httpx
      inquirerpy
      pydantic
      rich
      pycryptodomex
      yt-dlp
      thefuzz
      mpv
    ];

    doCheck = false;
  };

  # Enhanced ani-cli with built-in multi-source support and bundled dependencies
  ani-cli-multi = pkgs.writeShellApplication {
    name = "ani-cli";
    runtimeInputs = with pkgs; [
      ani-cli
      fastanime
      mov-cli
      animdl
      fzf
      mpv
      yt-dlp
      curl
      gnused
      gnugrep
      coreutils
    ];
    text = ''
      # Custom multi-source wrapper for ani-cli
      # Supported sources: anidb, allanime, hianime, animepahe, yugen, gogoanime, nyaa

      # Auto-initialize fastanime config directory if missing to prevent first-run block
      if [ ! -d "$HOME/.config/fastanime" ]; then
        mkdir -p "$HOME/.config/fastanime"
        echo '{"provider": "hianime"}' > "$HOME/.config/fastanime/config.json" 2>/dev/null || true
      fi

      SOURCE="''${ANI_CLI_SOURCE:-anidb}"
      ARGS=()

      # Parse command line flags
      while [ $# -gt 0 ]; do
        case "$1" in
          --source|-s|--provider)
            if [ -n "''${2:-}" ] && [[ "$2" != -* ]]; then
              SOURCE="$2"
              shift 2
            else
              SOURCE="select"
              shift 1
            fi
            ;;
          --source=*)
            SOURCE="''${1#*=}"
            shift 1
            ;;
          --help|-h)
            echo "ani-cli (Multi-Source Enabled)"
            echo ""
            echo "Multi-Source Options:"
            echo "  -s, --source <name>   Specify source provider:"
            echo "                        anidb (default), hianime, animepahe, allanime, yugen, gogoanime, nyaa, select"
            echo "                        (or set environment variable ANI_CLI_SOURCE)"
            echo ""
            echo "Standard ani-cli Options:"
            exec ${pkgs.ani-cli}/bin/ani-cli --help
            ;;
          *)
            ARGS+=("$1")
            shift 1
            ;;
        esac
      done

      # Interactive selection if requested
      if [ "$SOURCE" = "select" ] || [ "$SOURCE" = "list" ]; then
        if command -v fzf >/dev/null 2>&1; then
          SOURCE=$(printf "anidb\nhianime\nanimepahe\nallanime\nyugen\ngogoanime\nnyaa" | fzf --reverse --prompt="Select Anime Source: " || echo "anidb")
        else
          echo "Available sources: anidb, hianime, animepahe, allanime, yugen, gogoanime, nyaa"
          read -rp "Select source [anidb]: " CHOICE
          SOURCE="''${CHOICE:-anidb}"
        fi
      fi

      # Route to target scraper engine based on chosen source
      case "$SOURCE" in
        anidb|allanime)
          exec ${pkgs.ani-cli}/bin/ani-cli "''${ARGS[@]}"
          ;;
        hianime|animepahe|yugen|gogoanime|nyaa)
          FAST_ARGS=("--provider" "$SOURCE")
          QUERY=""
          for arg in "''${ARGS[@]}"; do
            case "$arg" in
              --dub) FAST_ARGS+=("--dub") ;;
              -d|--download) FAST_ARGS=("download" "''${FAST_ARGS[@]}") ;;
              *) QUERY="$QUERY $arg" ;;
            esac
          done
          QUERY=$(echo "$QUERY" | xargs)
          if [ -z "$QUERY" ]; then
            exec fastanime search "''${FAST_ARGS[@]}"
          else
            exec fastanime search "''${FAST_ARGS[@]}" "$QUERY"
          fi
          ;;
        *)
          echo "Unknown source: $SOURCE. Defaulting to anidb..."
          exec ${pkgs.ani-cli}/bin/ani-cli "''${ARGS[@]}"
          ;;
      esac
    '';
  };
in
{
  options.myFeatures.programs.media.ani-cli.enable = lib.mkEnableOption "ani-cli CLI anime player";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      home.packages = [
        ani-cli-multi
      ];
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && pkgs.stdenv.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".local/state/ani-cli"
              ".cache/ani-cli"
              ".config/fastanime"
              ".local/state/fastanime"
            ];
          });
        };
  };
}
