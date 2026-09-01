{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.tf2;

  # RCON helper script for scrims, matches, and server administration
  tf2RconScript = pkgs.writeShellScriptBin "tf2-rcon" ''
        set -euo pipefail

        print_help() {
          cat <<'EOF'
    TF2 Competitive RCON Helper
    ===========================
    Usage:
      tf2-rcon [host:port] [password] [command...]
      tf2-rcon [command...] (if TF2_RCON_SERVER & TF2_RCON_PASSWORD env vars are set)

    Convenience Commands:
      pause              - Pause match (rcon pause)
      unpause            - Unpause match (rcon unpause)
      restart            - Restart tournament match (rcon mp_tournament_restart 1)
      exec <config>      - Execute league config (e.g. rgl_6s_5cp, rgl_6s_koth, rgl_hl_stopwatch, etf2l_6v6_5cp)
      say <message>      - Broadcast server chat message
      pass <password>    - Set server join password (rcon sv_password <password>)
      status             - Show server player status
      map <mapname>      - Change level (rcon changelevel <mapname>)
      interactive        - Launch interactive RCON shell

    Environment Variables:
      TF2_RCON_SERVER    - Default server host:port (e.g. "12.34.56.78:27015")
      TF2_RCON_PASSWORD  - Default RCON admin password
    EOF
        }

        SERVER="''${TF2_RCON_SERVER:-}"
        PASSWORD="''${TF2_RCON_PASSWORD:-}"

        # Parse arguments
        if [ "$#" -ge 2 ] && [[ "$1" == *:* ]] && [[ "$1" != "exec" ]]; then
          SERVER="$1"
          PASSWORD="$2"
          shift 2
        elif [ "$#" -ge 2 ] && [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
          SERVER="$1"
          PASSWORD="$2"
          shift 2
        fi

        if [ -z "$SERVER" ] || [ -z "$PASSWORD" ]; then
          if [ "$#" -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
            print_help
            exit 0
          fi
          echo "Error: Server and password must be provided as arguments or via TF2_RCON_SERVER / TF2_RCON_PASSWORD environment variables."
          echo "Run 'tf2-rcon --help' for details."
          exit 1
        fi

        HOST="''${SERVER%:*}"
        PORT="''${SERVER##*:}"
        if [ "$HOST" = "$PORT" ]; then
          PORT="27015"
        fi

        CMD="''${1:-interactive}"

        case "$CMD" in
          pause)
            echo ">> Pausing match..."
            ${pkgs.mcrcon}/bin/mcrcon -H "$HOST" -P "$PORT" -p "$PASSWORD" "pause"
            ;;
          unpause)
            echo ">> Unpausing match..."
            ${pkgs.mcrcon}/bin/mcrcon -H "$HOST" -P "$PORT" -p "$PASSWORD" "unpause"
            ;;
          restart)
            echo ">> Restarting tournament match..."
            ${pkgs.mcrcon}/bin/mcrcon -H "$HOST" -P "$PORT" -p "$PASSWORD" "mp_tournament_restart 1"
            ;;
          exec)
            shift
            CONF="''${1:-rgl_6s_5cp}"
            echo ">> Executing tournament config: $CONF..."
            ${pkgs.mcrcon}/bin/mcrcon -H "$HOST" -P "$PORT" -p "$PASSWORD" "exec $CONF"
            ;;
          say)
            shift
            MSG="$*"
            ${pkgs.mcrcon}/bin/mcrcon -H "$HOST" -P "$PORT" -p "$PASSWORD" "say $MSG"
            ;;
          pass)
            shift
            NEWPASS="$1"
            echo ">> Setting server password..."
            ${pkgs.mcrcon}/bin/mcrcon -H "$HOST" -P "$PORT" -p "$PASSWORD" "sv_password \"$NEWPASS\""
            ;;
          status)
            ${pkgs.mcrcon}/bin/mcrcon -H "$HOST" -P "$PORT" -p "$PASSWORD" "status"
            ;;
          map)
            shift
            MAPNAME="$1"
            echo ">> Changing map to $MAPNAME..."
            ${pkgs.mcrcon}/bin/mcrcon -H "$HOST" -P "$PORT" -p "$PASSWORD" "changelevel $MAPNAME"
            ;;
          interactive)
            echo "Connecting to $HOST:$PORT (Interactive RCON shell - type 'exit' to quit)..."
            ${pkgs.mcrcon}/bin/mcrcon -H "$HOST" -P "$PORT" -p "$PASSWORD" -t
            ;;
          *)
            ${pkgs.mcrcon}/bin/mcrcon -H "$HOST" -P "$PORT" -p "$PASSWORD" "$*"
            ;;
        esac
  '';

  # CLI helper for generating/managing competitive TF2 autoexec, null movement, and HUD tools
  tf2CompSetupScript = pkgs.writeShellScriptBin "tf2-comp-setup" ''
        set -euo pipefail

        find_tf_dir() {
          POSSIBLE_PATHS=(
            "$HOME/.local/share/Steam/steamapps/common/Team Fortress 2/tf"
            "$HOME/.steam/root/steamapps/common/Team Fortress 2/tf"
            "$HOME/.steam/steam/steamapps/common/Team Fortress 2/tf"
          )
          for p in "''${POSSIBLE_PATHS[@]}"; do
            if [ -d "$p" ]; then
              echo "$p"
              return 0
            fi
          done
          echo ""
        }

        TF_DIR="$(find_tf_dir)"

        print_usage() {
          cat <<'EOF'
    TF2 Competitive Setup & Tooling
    ===============================
    Usage:
      tf2-comp-setup --status              Check TF2 installation and config status
      tf2-comp-setup --install-autoexec    Generate/install recommended competitive autoexec.cfg
      tf2-comp-setup --install-null-move   Generate standalone null-cancelling movement script
      tf2-comp-setup --launch-options      Show optimal Linux competitive launch options
      tf2-comp-setup --huds                Show competitive HUD recommendations and resources
      tf2-comp-setup --help                Show this message
    EOF
        }

        cmd="''${1:---status}"

        case "$cmd" in
          --status)
            echo "=== Team Fortress 2 Competitive Environment ==="
            if [ -n "$TF_DIR" ] && [ -d "$TF_DIR" ]; then
              echo "✔ TF2 Directory found: $TF_DIR"
              echo "  - Cfg dir:    $TF_DIR/cfg"
              echo "  - Custom dir: $TF_DIR/custom"
              if [ -f "$TF_DIR/cfg/autoexec.cfg" ]; then
                echo "  ✔ autoexec.cfg: PRESENT ($(wc -l < "$TF_DIR/cfg/autoexec.cfg") lines)"
              else
                echo "  ✖ autoexec.cfg: NOT FOUND (run 'tf2-comp-setup --install-autoexec')"
              fi
              if [ -f "$TF_DIR/cfg/null_movement.cfg" ]; then
                echo "  ✔ null_movement.cfg: PRESENT"
              fi
            else
              echo "⚠ TF2 installation not found at default Steam paths."
              echo "  Make sure Team Fortress 2 is installed via Steam."
            fi
            echo ""
            echo "Tools Available:"
            echo "  - Mumble VoIP:       $(command -v mumble || echo 'Not installed')"
            echo "  - VPK Editor:        $(command -v vpkedit || echo 'Not installed')"
            echo "  - RCON Tool:         $(command -v tf2-rcon || echo 'Not installed')"
            echo "  - Match Logs Search: $(command -v tf2-logs || echo 'Not installed')"
            echo "  - Demos Search:      $(command -v tf2-demos || echo 'Not installed')"
            ;;

          --launch-options)
            cat <<'EOF'
    === Recommended Competitive Launch Options (Linux 64-bit / Vulkan) ===
    In Steam -> Right-click Team Fortress 2 -> Properties -> Launch Options:

      gamemoderun %command% -novid -nojoy -nosteamcontroller -nohltv -particles 1 -snoforceformat

    Optional add-ons:
      - If using MangoHud:  mangohud gamemoderun %command% ...
      - If using Gamescope: gamescope -W 2560 -H 1440 -r 180 -- gamemoderun %command% ...
      - To set custom resolution: -w 2560 -h 1440 -fullscreen
    EOF
            ;;

          --huds)
            cat <<'EOF'
    === Popular Competitive TF2 HUDs & Resources ===
    HUDs can be placed into: ~/.local/share/Steam/steamapps/common/Team Fortress 2/tf/custom/

    1. budhud:      https://github.com/RaphPlayer/budhud
    2. mastercomhud:https://github.com/mastercomfig/mastercomfig
    3. ahud:        https://github.com/n0kk/ahud
    4. rayshud:     https://github.com/raysfire/rayshud
    5. toonhud:     https://toonhud.com/
    6. sunsethud:   https://github.com/Hypnootize/sunsethud

    VPK / Mod Inspection:
      Use 'vpkedit' GUI to view, extract, and customize VPK files.

    Leagues & Matchmaking:
      - RGL.gg (North America):      https://rgl.gg
      - ETF2L (Europe):              https://etf2l.org
      - TF2Center (PUGs/Lobbies):    https://tf2center.com
      - TF2Pickup:                   https://tf2pickup.org
      - logs.tf (Match Statistics):  https://logs.tf
      - demos.tf (Match Demos):      https://demos.tf
    EOF
            ;;

          --install-null-move)
            if [ -z "$TF_DIR" ]; then
              echo "Error: TF2 directory not found. Please launch or install TF2 first."
              exit 1
            fi
            mkdir -p "$TF_DIR/cfg"
            cat <<'EOF' > "$TF_DIR/cfg/null_movement.cfg"
    // ==========================================
    // Null-Cancelling Movement Script
    // Prevents opposing movement keys from stopping you
    // ==========================================
    alias +mfwd "-back;+forward;alias checkfwd +forward"
    alias +mback "-forward;+back;alias checkback +back"
    alias +mleft "-moveright;+moveleft;alias checkleft +moveleft"
    alias +mright "-moveleft;+moveright;alias checkright +moveright"
    alias -mfwd "-forward;checkback;alias checkfwd none"
    alias -mback "-back;checkfwd;alias checkback none"
    alias -mleft "-moveleft;checkright;alias checkleft none"
    alias -mright "-moveright;checkleft;alias checkright none"
    alias checkfwd none
    alias checkback none
    alias checkleft none
    alias checkright none
    alias none ""

    bind w +mfwd
    bind s +mback
    bind a +mleft
    bind d +mright
    echo "[TF2-Comp] Null-cancelling movement script loaded!"
    EOF
            echo "✔ Installed null_movement.cfg to $TF_DIR/cfg/null_movement.cfg"
            ;;

          --install-autoexec)
            if [ -z "$TF_DIR" ]; then
              echo "Error: TF2 directory not found. Please launch or install TF2 first."
              exit 1
            fi
            mkdir -p "$TF_DIR/cfg"
            TARGET="$TF_DIR/cfg/autoexec.cfg"
            if [ -f "$TARGET" ]; then
              BACKUP="$TARGET.backup.$(date +%s)"
              cp "$TARGET" "$BACKUP"
              echo "Backed up existing autoexec.cfg to $BACKUP"
            fi

            cat <<'EOF' > "$TARGET"
    // =========================================================================
    // Solar Competitive Team Fortress 2 Autoexec Configuration
    // =========================================================================

    // --- 1. Competitive Networking & Interpolation ---
    rate 196608
    cl_cmdrate 66
    cl_updaterate 66
    cl_interp_ratio 1
    cl_interp 0.015152
    cl_smooth 0
    cl_smoothtime 0.01
    cl_pred_optimize 2

    // Quick interpolation presets for hitscan vs projectile classes
    alias interp_projectile "cl_interp 0.015152; cl_interp_ratio 1; echo [TF2-Comp] Interpolation set to PROJECTILE (15.2ms)"
    alias interp_hitscan    "cl_interp 0.030303; cl_interp_ratio 2; echo [TF2-Comp] Interpolation set to HITSCAN (30.3ms)"
    alias interp_lan        "cl_interp 0.0; cl_interp_ratio 1; echo [TF2-Comp] Interpolation set to LAN"

    // --- 2. Null-Cancelling Movement Script ---
    alias +mfwd "-back;+forward;alias checkfwd +forward"
    alias +mback "-forward;+back;alias checkback +back"
    alias +mleft "-moveright;+moveleft;alias checkleft +moveleft"
    alias +mright "-moveleft;+moveright;alias checkright +moveright"
    alias -mfwd "-forward;checkback;alias checkfwd none"
    alias -mback "-back;checkfwd;alias checkback none"
    alias -mleft "-moveleft;checkright;alias checkleft none"
    alias -mright "-moveright;checkleft;alias checkright none"
    alias checkfwd none
    alias checkback none
    alias checkleft none
    alias checkright none
    alias none ""

    bind w +mfwd
    bind s +mback
    bind a +mleft
    bind d +mright

    // --- 3. Medic Uber Radar (Team Wallhack Beeper) ---
    // Holding 'c' lowers the autocall threshold to show all nearby teammates through walls
    alias +radar "hud_medicautocallersthreshold 300"
    alias -radar "hud_medicautocallersthreshold 75"
    bind c +radar

    // --- 4. Valve Automatic Match Demo Recording (P-REC replacement) ---
    ds_enable 2             // 2 = Automatically record competitive match demos
    ds_dir demos            // Store in tf/demos/
    ds_prefix comp_match
    ds_min_streak 4
    ds_kill_delay 15
    ds_notify 1             // Print recording status to console & chat
    ds_sound 1              // Play chime on record start/stop
    ds_screens 1            // Take screenshot of scoreboard at match end
    ds_autodelete 0         // Never delete match demos automatically

    // --- 5. Damage Numbers, Hitsounds, and Combat Text ---
    hud_combattext 1
    hud_combattext_batching 1
    hud_combattext_batching_window 2.0
    tf_dingalingaling 1
    tf_dingalingaling_lasthit 1
    tf_dingaling_volume 0.75
    tf_dingaling_pitchmindmg 140
    tf_dingaling_pitchmaxdmg 50

    // --- 6. Instant Loadout / Spawn Presets ---
    bind F1 "load_itempreset 0"
    bind F2 "load_itempreset 1"
    bind F3 "load_itempreset 2"
    bind F4 "load_itempreset 3"

    // --- 7. Netgraph Toggle with Scoreboard ---
    alias +tabgraph "+showscores; net_graph 1"
    alias -tabgraph "-showscores; net_graph 0"
    bind TAB +tabgraph

    // --- 8. Fast Crouch Jump Script ---
    alias +cjump "+jump; +duck"
    alias -cjump "-duck; -jump"
    // To bind space to crouch jump, uncomment below:
    // bind SPACE +cjump

    echo "========================================================"
    echo " [Solar] Competitive TF2 Autoexec Loaded Successfully!  "
    echo " Presets: 'interp_projectile', 'interp_hitscan', 'interp_lan' "
    echo "========================================================"
    EOF
            echo "✔ Successfully generated competitive autoexec.cfg in $TARGET"
            ;;

          *)
            print_usage
            ;;
        esac
  '';

  # CLI helper to query or open match logs on logs.tf
  tf2LogsScript = pkgs.writeShellScriptBin "tf2-logs" ''
    set -euo pipefail
    TARGET="''${1:-}"

    if [ -z "$TARGET" ] || [ "$TARGET" = "-h" ] || [ "$TARGET" = "--help" ]; then
      echo "Usage: tf2-logs <match_id | search_term | player_id>"
      echo "Examples:"
      echo "  tf2-logs 3512345        (Opens match 3512345 on logs.tf)"
      echo "  tf2-logs 'Froyotech'    (Searches for Froyotech matches)"
      echo "  tf2-logs 76561198...    (Searches by SteamID64)"
      exit 0
    fi

    if [[ "$TARGET" =~ ^[0-9]{6,8}$ ]]; then
      URL="https://logs.tf/$TARGET"
    else
      QUERY=$(echo "$TARGET" | tr ' ' '+')
      URL="https://logs.tf/search?q=$QUERY"
    fi

    echo "Opening: $URL"
    if command -v xdg-open >/dev/null 2>&1; then
      xdg-open "$URL" >/dev/null 2>&1 &
    elif command -v open >/dev/null 2>&1; then
      open "$URL"
    else
      echo "Visit: $URL"
    fi
  '';

  # CLI helper to query or open demos on demos.tf
  tf2DemosScript = pkgs.writeShellScriptBin "tf2-demos" ''
    set -euo pipefail
    TARGET="''${1:-}"

    if [ -z "$TARGET" ] || [ "$TARGET" = "-h" ] || [ "$TARGET" = "--help" ]; then
      echo "Usage: tf2-demos <demo_id | map_name | player_name>"
      echo "Examples:"
      echo "  tf2-demos 123456          (Opens demo 123456 on demos.tf)"
      echo "  tf2-demos cp_process_f12  (Searches demos for cp_process)"
      exit 0
    fi

    if [[ "$TARGET" =~ ^[0-9]+$ ]]; then
      URL="https://demos.tf/$TARGET"
    else
      QUERY=$(echo "$TARGET" | tr ' ' '+')
      URL="https://demos.tf/?query=$QUERY"
    fi

    echo "Opening: $URL"
    if command -v xdg-open >/dev/null 2>&1; then
      xdg-open "$URL" >/dev/null 2>&1 &
    elif command -v open >/dev/null 2>&1; then
      open "$URL"
    else
      echo "Visit: $URL"
    fi
  '';
in
{
  options.myFeatures.programs.media.tf2 = {
    enable = lib.mkEnableOption "Competitive Team Fortress 2 Suite & Toolchain";

    mumble = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Mumble voice client integration with positional audio and Wayland push-to-talk";
      };
    };

    rcon = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable RCON server administration tools (mcrcon and tf2-rcon CLI helper)";
      };
    };

    vpkTools = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable VPK package and custom HUD / hitsound editing tools (vpkedit)";
      };
    };

    compHelper = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install tf2-comp-setup CLI helper for autoexec generation, null-cancelling movement, and league configs";
      };
    };

    logsHelper = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install tf2-logs and tf2-demos match viewer and lookup CLI tools";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure Steam is enabled
    myFeatures.programs.media.steam.enable = lib.mkDefault true;

    # Enable Mumble when requested
    myFeatures.programs.media.mumble.enable = lib.mkIf cfg.mumble.enable (lib.mkDefault true);

    # Ensure Gamemode is enabled for optimal CPU/GPU scheduler performance
    programs.gamemode.enable = lib.mkDefault true;

    # System packages for competitive TF2 tooling
    environment.systemPackages =
      lib.optionals cfg.rcon.enable [
        pkgs.mcrcon
        tf2RconScript
      ]
      ++ lib.optionals cfg.vpkTools.enable [
        pkgs.vpkedit
      ]
      ++ lib.optionals cfg.compHelper.enable [
        tf2CompSetupScript
      ]
      ++ lib.optionals cfg.logsHelper.enable [
        tf2LogsScript
        tf2DemosScript
      ];

    # Impermanence preservation for VPKEdit & TF2 tool state
    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && pkgs.stdenv.hostPlatform.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/vpkedit"
            ];
          });
        };
  };
}
