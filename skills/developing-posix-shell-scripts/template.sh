#!/bin/sh

set -e
set -u

SCRIPT_NAME="$(basename "${0}")"

# Logging configuration
# Levels: 10=DEBUG, 20=INFO, 30=WARNING, 40=ERROR, 50=CRITICAL
LOG_LEVEL="INFO"
LOG_FORMAT="simple" # simple, level, full

# Helper to get priority from level name
get_log_priority() {
    case "${1}" in
        DEBUG) echo 10 ;;
        INFO) echo 20 ;;
        WARNING) echo 30 ;;
        ERROR) echo 40 ;;
        CRITICAL) echo 50 ;;
        *) echo 0 ;; # Unknown
    esac
}

# Logging functions
log_color() {
    _color="${1}"
    shift
    if [ -t 2 ]; then
        # shellcheck disable=SC2059
        printf "\033[0;%sm%s\033[0m\n" "${_color}" "${*}" >&2
    else
        printf "%s\n" "${*}" >&2
    fi
}

log_message() {
    _color="${1}"
    _level="${2}"
    shift 2

    # Get standard variables (global scope in POSIX sh)
    # Calculate priorities
    _current_prio=$(get_log_priority "${LOG_LEVEL}")
    _msg_prio=$(get_log_priority "${_level}")

    if [ "${_msg_prio}" -lt "${_current_prio}" ]; then
        return 0
    fi

    # Format message
    case "${LOG_FORMAT}" in
        simple)
            log_color "${_color}" "${*}"
            ;;
        level)
            log_color "${_color}" "[${_level}] ${*}"
            ;;
        full)
            # Use 'date' if available, otherwise simple formatted
            if command -v date >/dev/null 2>&1; then
                 # ISO-8601-ish depending on implementation, here simply calling date
                 _timestamp=$(date "+%Y-%m-%dT%H:%M:%S")
                 log_color "${_color}" "[${_timestamp}][${_level}] ${*}"
            else
                 log_color "${_color}" "[${_level}] ${*}"
            fi
            ;;
        *)
            log_color "${_color}" "${*}"
            ;;
    esac
}

log_error() {
    log_message "31" "ERROR" "${@}"
}

log_info() {
    log_message "32" "INFO" "${@}"
}

log_warning() {
    log_message "33" "WARNING" "${@}"
}

log_debug() {
    log_message "34" "DEBUG" "${@}"
}

set_log_level() {
    _level=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    case "${_level}" in
        DEBUG | INFO | WARNING | ERROR | CRITICAL)
            LOG_LEVEL="${_level}"
            ;;
        *)
            log_error "Invalid log level: ${1}. Valid levels: DEBUG, INFO, WARNING, ERROR, CRITICAL"
            exit 1
            ;;
    esac
}

# Usage information
usage() {
    _exit_code="${1:-0}"
    cat <<EOF
USAGE:
    ${SCRIPT_NAME} [OPTIONS]

    A POSIX shell script template

OPTIONS:
    -h          Show this help message
    -l LEVEL    Set log level (DEBUG, INFO, WARNING, ERROR)
                Default: INFO
    -a ARG      Set ALPHA
    -b ARG      Set BRAVO
    -c ARG      Set CHARLIE

EXAMPLES:
    ${SCRIPT_NAME} -a bravo
    ${SCRIPT_NAME} -l DEBUG
EOF
    exit "${_exit_code}"
}

# Parse command line arguments
parse_args() {
    # Default values
    ALPHA="alpha"
    BRAVO="bravo"
    CHARLIE="charlie"

    while getopts ":hl:a:b:c:" opt; do
        case "${opt}" in
            h)
                usage 0
                ;;
            l)
                set_log_level "${OPTARG}"
                ;;
            a)
                ALPHA="${OPTARG}"
                ;;
            b)
                BRAVO="${OPTARG}"
                ;;
            c)
                CHARLIE="${OPTARG}"
                ;;
            \?)
                log_error "Invalid option: -${OPTARG}"
                usage 1
                ;;
            :)
                log_error "Option -${OPTARG} requires an argument."
                usage 1
                ;;
        esac
    done
    shift $((OPTIND - 1))

    # Remaining arguments
    if [ "$#" -gt 0 ]; then
        # POSIX sh does not have arrays to store arbitrary remaining args easily without $@
        # But $@ stays valid
        log_debug "Remaining arguments: $*"
    fi
}

main() {
    parse_args "$@"

    log_debug "Log level: ${LOG_LEVEL}"
    log_info "ALPHA=${ALPHA}"
    log_info "BRAVO=${BRAVO}"
    log_info "CHARLIE=${CHARLIE}"
}

main "$@"
