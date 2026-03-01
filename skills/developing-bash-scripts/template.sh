#!/usr/bin/env bash

set -o errexit -o nounset -o errtrace

SCRIPT_FILE="$(readlink -f "${0}")"
SCRIPT_NAME="$(basename "${SCRIPT_FILE}")"

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

# Logging functions
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
        simple)
            log_color "${color}" "${message}"
            ;;
        level)
            log_color "${color}" "[${level}] ${message}"
            ;;
        full)
            log_color "${color}" "[$(date --utc --iso-8601=seconds)][${level}] ${message}"
            ;;
        *)
            log_color "${color}" "${message}"
            ;;
    esac
}

log_error() {
    local RED=31
    log_message "${RED}" "ERROR" "${@}"
}

log_info() {
    local GREEN=32
    log_message "${GREEN}" "INFO" "${@}"
}

log_warning() {
    local YELLOW=33
    log_message "${YELLOW}" "WARNING" "${@}"
}

log_debug() {
    local BLUE=34
    log_message "${BLUE}" "DEBUG" "${@}"
}

log_critical() {
    local CYAN=36
    log_message "${CYAN}" "CRITICAL" "${@}"
}

# Set log level with validation
set_log_level() {
    local level="${1^^}" # Convert to uppercase
    if [[ -z "${LOG_PRIORITY[${level}]:-}" ]]; then
        log_error "Invalid log level: ${1}. Valid levels: ERROR, WARNING, INFO, DEBUG"
        exit 1
    fi
    LOG_LEVEL="${level}"
}

# Set log format with validation
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

# Check if required commands are available
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

# Cleanup handler
cleanup() {
    local exit_code=$?
    # Add cleanup logic here (e.g., remove temp files)
    exit "${exit_code}"
}

trap cleanup EXIT INT TERM

# Show usage information
usage() {
    local exit_code="${1:-0}"
    cat <<EOF
USAGE:
    ${SCRIPT_NAME} [OPTIONS]

    A getopt example shell script

OPTIONS:
    -h, --help                Show this help message
    --log-level LEVEL         Set log level (ERROR, WARNING, INFO, DEBUG)
                              Default: INFO
    --log-format FORMAT       Set log output format (simple, level, full)
                              simple: message only
                              level:  [LEVEL] message
                              full:   [timestamp][LEVEL] message
                              Default: simple
    -a, --alpha ARG           Set ALPHA
    -b, --bravo ARG           Set BRAVO
    -c, --charlie ARG         Set CHARLIE

EXAMPLES:
    ${SCRIPT_NAME} --alpha bravo
    ${SCRIPT_NAME} --log-level DEBUG --log-format full
    ${SCRIPT_NAME} --log-format level

EOF
    exit "${exit_code}"
}

# Parse command line arguments
parse_args() {
    local args
    local options="ha:b:c:"
    local longoptions="help,log-level:,log-format:,alpha:,bravo:,charlie:"
    if ! args=$(getopt --options="${options}" --longoptions="${longoptions}" --name="${SCRIPT_NAME}" -- "${@}"); then
        usage 1
    fi

    eval set -- "${args}"
    declare -g -a REST_ARGS=()

    declare -g ALPHA="alpha"
    declare -g BRAVO="bravo"
    declare -g CHARLIE="charlie"

    while true; do
        case "${1}" in
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
            -a | --alpha)
                ALPHA="${2}"
                shift 2
                ;;
            -b | --bravo)
                BRAVO="${2}"
                shift 2
                ;;
            -c | --charlie)
                CHARLIE="${2}"
                shift 2
                ;;
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

    # Capture remaining positional arguments
    REST_ARGS=("${@}")
}

main() {
    require_command getopt

    parse_args "${@}"

    log_debug "Log level: ${LOG_LEVEL}, Log format: ${LOG_FORMAT}"
    log_info "ALPHA=${ALPHA}"
    log_info "BRAVO=${BRAVO}"
    log_info "CHARLIE=${CHARLIE}"

    # https://www.shellcheck.net/wiki/SC2145
    if [[ ${#REST_ARGS[@]} -gt 0 ]]; then
        log_debug "Remaining arguments: ${REST_ARGS[*]}"
    fi
}

main "${@}"
