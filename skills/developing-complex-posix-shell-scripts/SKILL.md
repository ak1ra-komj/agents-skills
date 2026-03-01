---
name: developing-complex-posix-shell-scripts
description: Guidelines for writing production-ready, complex POSIX shell scripts (/bin/sh) with structured logging, argument parsing, and robust error handling. Provides reusable code snippets for each component instead of a monolithic template.
---

# developing-complex-posix-shell-scripts skill

This skill defines guidelines for writing **complex** POSIX shell scripts: production utilities, reusable system tools, or scripts that require multiple flags, structured logging, or robust error handling — while remaining strictly portable.

Use **developing-simple-posix-shell-scripts** for ad-hoc tasks or scripts under ~50 lines without CLI scaffolding.

## When to Use This Skill

- Reusable system utilities or production automation scripts targeting `/bin/sh`
- Scripts with multiple named flags / options
- Requires structured logging with severity levels
- Needs `-h` / help output
- Has cleanup logic, dependency checks, or complex control flow
- Must run portably on Alpine, BusyBox, embedded, or other minimal systems

## Core Requirements

### Shebang & Safety Modes

```sh
#!/bin/sh

set -e
set -u
```

- `set -e`: exit immediately on error.
- `set -u`: exit on reference to an unset variable.
- `set -o pipefail` is **not** POSIX — do not use it.

### Tooling

- All scripts MUST pass `shellcheck --shell=sh` without warnings.
- Format with `shfmt -ln posix` before considering the script done.

### POSIX Compliance — Do NOT Use These Bash-isms

| Bash feature                  | POSIX replacement                                   |
| ----------------------------- | --------------------------------------------------- |
| `[[ ... ]]`                   | `[ ... ]`                                           |
| `local var`                   | prefix with `_funcname_var` (see Variables section) |
| `declare -a arr`              | not available — restructure logic                   |
| `source file`                 | `. file`                                            |
| `function f { }`              | `f() { }`                                           |
| `(( expr ))`                  | `$(( expr ))`                                       |
| `$'...'` strings              | `printf`                                            |
| `<<<` here-strings            | `printf ... \|` or temp file                        |
| `<(cmd)` process substitution | temp file or pipe                                   |
| `echo -e`                     | `printf`                                            |

### Variables & Quoting

- Always use `${var}` (braces) for variable expansion.
- Always quote expansions: `"${var}"`.
- POSIX `sh` has no `local` keyword. Simulate function-local variables by prefixing with the function name: `_log_message_color`, `_parse_args_opt`, etc. Unset them at the end of the function if needed.
- Use `$(...)` for command substitution, never backticks.
- Prefer `printf` over `echo` for reliable, portable output.

---

## Reference Code Blocks

Pick and compose the sections you need. Do NOT copy everything blindly — only include what the script actually uses.

### 1. Script Identity

```sh
SCRIPT_NAME="$(basename "${0}")"
```

### 2. Logging Subsystem

Use this block when the script needs more than simple `printf` output. Because POSIX `sh` has no associative arrays, level priorities are resolved via a helper function.

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
```

### 3. Log Level & Format Setters

Include these when the script exposes `-l` / log-format flags.

```sh
set_log_level() {
    # tr to uppercase without bashism
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

### 4. Dependency Check

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

### 5. Cleanup Handler

Include this when the script creates temporary files or resources that must be cleaned up on exit.

```sh
cleanup() {
    _cleanup_exit_code=$?
    # Add cleanup logic here (e.g., rm -f "${_tmpfile:-}")
    exit "${_cleanup_exit_code}"
}

trap cleanup EXIT INT TERM
```

### 6. Usage / Help

**Argument ordering convention**: list template flags first (`-h`, `-l`, `-f`), then script-specific flags. This mirrors the ordering required in the `getopts` optstring and `case` statement (see Section 7), keeping all three in sync.

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

### 7. Argument Parsing

Use `getopts` (POSIX built-in, short options only). Adjust the optstring to match the script's flags.

**Argument ordering convention**: template flags come first in the optstring and `case` statement, script-specific flags come after. This keeps `usage`, `getopts` optstring, and `case` in sync.

```sh
parse_args() {
    # --- template flag defaults ---
    # LOG_LEVEL and LOG_FORMAT already defaulted at top of script

    # --- script-specific flag defaults ---
    # MY_FLAG="default"

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

### 8. Main Entry Point

```sh
main() {
    parse_args "${@}"

    log_debug "Log level: ${LOG_LEVEL}, Log format: ${LOG_FORMAT}"

    # Script logic here
}

main "${@}"
```

---

## Composition Guide

1. **Always include**: Script Identity + Shebang/Safety Modes + `main`.
2. **Include Logging Subsystem** when output needs severity levels or colour.
3. **Include Log Level/Format Setters** only when exposing `-l` / `-f` flags.
4. **Include Dependency Check** when relying on non-standard external commands.
5. **Include Cleanup Handler** when the script allocates resources (temp files, locks, etc.).
6. **Include Usage + Argument Parsing** when the script accepts any named flags.

Compose only the sections the script actually needs. A complex script with no temp files does not need a cleanup handler.
