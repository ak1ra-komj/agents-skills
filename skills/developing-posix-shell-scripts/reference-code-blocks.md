# Reference Code Blocks

Reusable code blocks for complex POSIX shell scripts. Pick and compose only the sections a script actually needs — do not copy everything blindly.

See [developing-complex-posix-shell-scripts.md](developing-complex-posix-shell-scripts.md) for the composition guide.

## 1. Script Identity

```sh
SCRIPT_NAME="$(basename "${0}")"
```

## 2. Logging Subsystem

Use this block when the script needs more than simple `printf` output. Because POSIX `sh` has no associative arrays, level priorities are resolved via a helper function. The setter functions (`set_log_level`, `set_log_format`) are included as part of this block — omit them only if the script does not expose `-l` / `-f` flags.

```sh
# Logging configuration
LOG_LEVEL="INFO"    # ERROR, WARNING, INFO, DEBUG
LOG_FORMAT="simple" # simple, level, full

get_log_priority() {
    case "${1}" in
        DEBUG)    printf '10' ;;
        INFO)     printf '20' ;;
        WARNING)  printf '30' ;;
        ERROR)    printf '40' ;;
        CRITICAL) printf '50' ;;
        *)        printf '0'  ;;
    esac
}

log_color() {
    _log_color_code="${1}"
    shift
    if [ -t 2 ]; then
        # shellcheck disable=SC2059
        printf "\033[0;%sm%s\033[0m\n" "${_log_color_code}" "${*}" >&2
    else
        printf '%s\n' "${*}" >&2
    fi
    unset _log_color_code
}

log_message() {
    _log_message_color="${1}"
    _log_message_level="${2}"
    shift 2

    _log_message_current_prio=$(get_log_priority "${LOG_LEVEL}")
    _log_message_msg_prio=$(get_log_priority "${_log_message_level}")

    if [ "${_log_message_msg_prio}" -lt "${_log_message_current_prio}" ]; then
        unset _log_message_color _log_message_level _log_message_current_prio _log_message_msg_prio
        return 0
    fi

    case "${LOG_FORMAT}" in
        simple) log_color "${_log_message_color}" "${*}" ;;
        level)  log_color "${_log_message_color}" "[${_log_message_level}] ${*}" ;;
        full)
            _log_message_ts=$(date '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || printf 'unknown')
            log_color "${_log_message_color}" "[${_log_message_ts}][${_log_message_level}] ${*}"
            unset _log_message_ts
            ;;
        *)      log_color "${_log_message_color}" "${*}" ;;
    esac
    unset _log_message_color _log_message_level _log_message_current_prio _log_message_msg_prio
}

log_error()    { log_message '31' 'ERROR'    "${@}"; }
log_info()     { log_message '32' 'INFO'     "${@}"; }
log_warning()  { log_message '33' 'WARNING'  "${@}"; }
log_debug()    { log_message '34' 'DEBUG'    "${@}"; }
log_critical() { log_message '36' 'CRITICAL' "${@}"; }

set_log_level() {
    _set_log_level_val=$(printf '%s' "${1}" | tr '[:lower:]' '[:upper:]')
    case "${_set_log_level_val}" in
        DEBUG | INFO | WARNING | ERROR | CRITICAL)
            LOG_LEVEL="${_set_log_level_val}"
            ;;
        *)
            log_error "Invalid log level: ${1}. Valid levels: DEBUG, INFO, WARNING, ERROR, CRITICAL"
            exit 1
            ;;
    esac
    unset _set_log_level_val
}

set_log_format() {
    case "${1}" in
        simple | level | full)
            LOG_FORMAT="${1}"
            ;;
        *)
            log_error "Invalid log format: ${1}. Valid formats: simple, level, full"
            exit 1
            ;;
    esac
}
```

## 3. Dependency Check

Include this when the script relies on external commands that may not be present.

```sh
require_command() {
    _require_command_missing=''
    for _require_command_c in "${@}"; do
        if ! command -v "${_require_command_c}" >/dev/null 2>&1; then
            _require_command_missing="${_require_command_missing} ${_require_command_c}"
        fi
    done

    if [ -n "${_require_command_missing}" ]; then
        log_error "Required command(s) not installed:${_require_command_missing}"
        log_error "Please install the missing dependencies and try again"
        exit 1
    fi
    unset _require_command_missing _require_command_c
}
```

## 4. Cleanup Handler

Include this when the script creates temporary files or resources that must be cleaned up on exit.

```sh
cleanup() {
    _cleanup_exit_code=$?
    # Add cleanup logic here (e.g., rm -f "${_tmpfile:-}")
    exit "${_cleanup_exit_code}"
}

trap cleanup EXIT INT TERM
```

## 5. Usage / Help

Adapt the OPTIONS and EXAMPLES sections to the actual flags of the script.

**Argument ordering convention**: list template flags first (`-h`, `-l`, `-f`), then script-specific flags. This mirrors the ordering required in the `getopts` optstring and `case` statement (see Section 6), keeping all three in sync.

```sh
usage() {
    _usage_exit_code="${1:-0}"
    cat <<EOF
USAGE:
    ${SCRIPT_NAME} [OPTIONS]

    Short description of what the script does.

OPTIONS:
    -h          Show this help message
    -l LEVEL    Set log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
                Default: INFO
    -f FORMAT   Set log format (simple, level, full)
                simple: message only
                level:  [LEVEL] message
                full:   [timestamp][LEVEL] message
                Default: simple
    <script-specific flags go here>

EXAMPLES:
    ${SCRIPT_NAME} -h
    ${SCRIPT_NAME} -l DEBUG -f full

EOF
    exit "${_usage_exit_code}"
}
```

## 6. Argument Parsing

Use `getopts` (POSIX built-in, short options only). Adjust the optstring to match the script's flags.

**Argument ordering convention**: template flags come first in the optstring and `case` statement, script-specific flags come after. This keeps `usage`, `getopts` optstring, and `case` in sync.

```sh
parse_args() {
    # template flags first (hl:f:), then script-specific flags
    while getopts ':hl:f:' _parse_args_opt; do
        case "${_parse_args_opt}" in
            # --- template flags (always first) ---
            h) usage 0 ;;
            l) set_log_level "${OPTARG}" ;;
            f) set_log_format "${OPTARG}" ;;
            # --- script-specific flags ---
            \?)
                log_error "Invalid option: -${OPTARG}"
                usage 1
                ;;
            :)
                log_error "Option -${OPTARG} requires an argument"
                usage 1
                ;;
        esac
    done
    shift $((OPTIND - 1))

    # Remaining positional arguments are now in "$@"
}
```

## 7. Main Entry Point

```sh
main() {
    parse_args "${@}"

    log_debug "Log level: ${LOG_LEVEL}, Log format: ${LOG_FORMAT}"

    # Script logic here
}

main "${@}"
```
