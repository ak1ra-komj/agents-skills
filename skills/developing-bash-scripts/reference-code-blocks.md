# Reference Code Blocks

Reusable code blocks for complex Bash scripts. Pick and compose only the sections a script actually needs — do not copy everything blindly.

See [developing-complex-bash-scripts.md](developing-complex-bash-scripts.md) for the composition guide.

## 1. Script Identity

```bash
SCRIPT_FILE="$(readlink -f "${0}")"
SCRIPT_NAME="$(basename "${SCRIPT_FILE}")"
```

## 2. Logging Subsystem

Use this block when the script needs more than simple `echo` output. The setter functions (`set_log_level`, `set_log_format`) are included as part of this block — omit them only if the script does not expose `--log-level` / `--log-format` flags.

```bash
# Logging configuration
declare -g LOG_LEVEL="INFO"    # ERROR, WARNING, INFO, DEBUG
declare -g LOG_FORMAT="simple" # simple, level, full

# Log level priorities
declare -g -A LOG_PRIORITY=(
    ["DEBUG"]=10
    ["INFO"]=20
    ["WARNING"]=30
    ["ERROR"]=40
    ["CRITICAL"]=50
)

log_color() {
    local color="${1}"
    shift
    if [[ -t 2 ]]; then
        printf "\x1b[0;%sm%s\x1b[0m\n" "${color}" "${*}" >&2
    else
        printf "%s\n" "${*}" >&2
    fi
}

log_message() {
    local color="${1}"
    local level="${2}"
    shift 2

    if [[ "${LOG_PRIORITY[$level]}" -lt "${LOG_PRIORITY[$LOG_LEVEL]}" ]]; then
        return 0
    fi

    local message="${*}"
    case "${LOG_FORMAT}" in
        simple) log_color "${color}" "${message}" ;;
        level)  log_color "${color}" "[${level}] ${message}" ;;
        full)   log_color "${color}" "[$(date --utc --iso-8601=seconds)][${level}] ${message}" ;;
        *)      log_color "${color}" "${message}" ;;
    esac
}

log_error()    { log_message 31 "ERROR"    "${@}"; }
log_info()     { log_message 32 "INFO"     "${@}"; }
log_warning()  { log_message 33 "WARNING"  "${@}"; }
log_debug()    { log_message 34 "DEBUG"    "${@}"; }
log_critical() { log_message 36 "CRITICAL" "${@}"; }

set_log_level() {
    local level="${1^^}"
    if [[ -z "${LOG_PRIORITY[${level}]:-}" ]]; then
        log_error "Invalid log level: ${1}. Valid levels: ERROR, WARNING, INFO, DEBUG"
        exit 1
    fi
    LOG_LEVEL="${level}"
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

```bash
require_command() {
    local missing=()
    for c in "${@}"; do
        if ! command -v "${c}" >/dev/null 2>&1; then
            missing+=("${c}")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Required command(s) not installed: ${missing[*]}"
        log_error "Please install the missing dependencies and try again"
        exit 1
    fi
}
```

## 4. Cleanup Handler

Include this when the script creates temporary files or resources that must be cleaned up on exit.

```bash
cleanup() {
    local exit_code=$?
    # Add cleanup logic here (e.g., rm -rf "${TMPDIR:-}")
    exit "${exit_code}"
}

trap cleanup EXIT INT TERM
```

## 5. Usage / Help

Adapt the OPTIONS and EXAMPLES sections to the actual flags of the script.

**Argument ordering convention**: in the OPTIONS block, list template flags first, then script-specific flags. This mirrors the ordering required in `longoptions` and the `case` statement (see Section 6), keeping all three in sync.

```bash
usage() {
    local exit_code="${1:-0}"
    cat <<EOF
USAGE:
    ${SCRIPT_NAME} [OPTIONS]

    Short description of what the script does.

OPTIONS:
    -h, --help                Show this help message
    --log-level LEVEL         Set log level (ERROR, WARNING, INFO, DEBUG)
                              Default: INFO
    --log-format FORMAT       Set log output format (simple, level, full)
                              simple: message only
                              level:  [LEVEL] message
                              full:   [timestamp][LEVEL] message
                              Default: simple
    <script-specific flags go here>

EXAMPLES:
    ${SCRIPT_NAME} --help
    ${SCRIPT_NAME} --log-level DEBUG --log-format full

EOF
    exit "${exit_code}"
}
```

## 6. Argument Parsing

Use `getopt` (not `getopts`) to support long options. Adjust `options`/`longoptions` to match the script's flags.

**Argument ordering convention**: infrastructure/template flags come first, script-specific flags come after — in both the `longoptions` string and the `case` statement. This keeps the interface predictable and the `case` block easy to scan.

```
longoptions="help,log-level:,log-format:,<script-flag-1>:,<script-flag-2>:"
                ^--- template flags first ---^  ^--- script flags after ---^
```

```bash
parse_args() {
    local args
    local options="h"
    local longoptions="help,log-level:,log-format:"
    if ! args=$(getopt --options="${options}" --longoptions="${longoptions}" --name="${SCRIPT_NAME}" -- "${@}"); then
        usage 1
    fi

    eval set -- "${args}"
    declare -g -a REST_ARGS=()

    while true; do
        case "${1}" in
            # --- template flags (always first) ---
            -h | --help)
                usage 0
                ;;
            --log-level)
                set_log_level "${2}"
                shift 2
                ;;
            --log-format)
                set_log_format "${2}"
                shift 2
                ;;
            # --- script-specific flags ---
            --)
                shift
                break
                ;;
            *)
                log_error "Unexpected option: ${1}"
                usage 1
                ;;
        esac
    done

    REST_ARGS=("${@}")
}
```

## 7. Main Entry Point

```bash
main() {
    require_command getopt

    parse_args "${@}"

    log_debug "Log level: ${LOG_LEVEL}, Log format: ${LOG_FORMAT}"

    # Script logic here
}

main "${@}"
```
