#!/usr/bin/env bash

set -o errexit -o nounset -o errtrace

SCRIPT_FILE="$(readlink -f "${0}")"
SCRIPT_NAME="$(basename "${SCRIPT_FILE}")"

readonly EXIT_PASS=0
readonly EXIT_FAIL=1
readonly EXIT_ENV=2
readonly EXIT_NO_FILES=3

declare -g WORKFLOW_DIR=".github/workflows"
declare -gi RUN_ACTIONLINT=1
declare -gi RUN_ZIZMOR=0
declare -gi HAS_FAILURE=0
declare -gi HAS_INCOMPLETE=0
declare -g -a FILES=()
declare -g -a REST_ARGS=()

log_error() { printf '[verify] ERROR: %s\n' "${*}" >&2; }
log_warning() { printf '[verify] WARNING: %s\n' "${*}" >&2; }

record_pass() { printf '[verify] %s: PASS%s\n' "${1}" "${2:+ (${2})}"; }
record_fail() { printf '[verify] %s: FAIL%s\n' "${1}" "${2:+ (${2})}"; }
record_skip() { printf '[verify] %s: SKIP%s\n' "${1}" "${2:+ (${2})}"; }
record_unavailable() { printf '[verify] %s: UNAVAILABLE%s\n' "${1}" "${2:+ (${2})}"; }
record_error() { printf '[verify] %s: ERROR%s\n' "${1}" "${2:+ (${2})}"; }

usage() {
    local exit_code="${1:-0}"
    cat <<EOF
USAGE:
    ${SCRIPT_NAME} [OPTIONS] [FILE...]

    Verify GitHub Actions workflow files. With no FILE arguments,
    discovers *.yml and *.yaml under ${WORKFLOW_DIR} (or --dir).

OPTIONS:
    -h, --help          Show this help message
    --dir DIR           Workflow directory (default: ${WORKFLOW_DIR})
    --security          Also run zizmor security analysis (offline)
    --no-actionlint     Skip actionlint

EXIT CODES:
    0   All requested checks passed
    1   Validation failed
    2   Tool unavailable, or usage or environment error
    3   No workflow files found

TOOLS:
    actionlint  https://github.com/rhysd/actionlint (MIT)
    zizmor      https://github.com/zizmorcore/zizmor (MIT)

EXAMPLES:
    ${SCRIPT_NAME}
    ${SCRIPT_NAME} --security
    ${SCRIPT_NAME} .github/workflows/ci.yml

EOF
    exit "${exit_code}"
}

require_command() {
    local command_name
    for command_name in "${@}"; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log_error "required command not installed: ${command_name}"
            exit "${EXIT_ENV}"
        fi
    done
}

parse_args() {
    local args
    local options="h"
    local longoptions="help,dir:,security,no-actionlint"
    if ! args=$(getopt --options="${options}" --longoptions="${longoptions}" --name="${SCRIPT_NAME}" -- "${@}"); then
        usage "${EXIT_ENV}"
    fi

    eval set -- "${args}"

    while true; do
        case "${1}" in
            -h | --help)
                usage 0
                ;;
            --dir)
                WORKFLOW_DIR="${2}"
                shift 2
                ;;
            --security)
                RUN_ZIZMOR=1
                shift
                ;;
            --no-actionlint)
                RUN_ACTIONLINT=0
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                log_error "unexpected option: ${1}"
                usage "${EXIT_ENV}"
                ;;
        esac
    done

    REST_ARGS=("${@}")
}

discover_files() {
    local dir="${1}"
    if [[ ! -d "${dir}" ]]; then
        log_error "workflow directory not found: ${dir}"
        exit "${EXIT_NO_FILES}"
    fi

    local -a found=()
    local file
    for file in "${dir}"/*.yml "${dir}"/*.yaml; do
        if [[ -e "${file}" ]]; then
            found+=("${file}")
        fi
    done

    if [[ ${#found[@]} -eq 0 ]]; then
        log_error "no workflow files (*.yml, *.yaml) found in ${dir}"
        exit "${EXIT_NO_FILES}"
    fi

    FILES=("${found[@]}")
}

resolve_files() {
    if [[ ${#REST_ARGS[@]} -eq 0 ]]; then
        discover_files "${WORKFLOW_DIR}"
        return 0
    fi

    local file
    for file in "${REST_ARGS[@]}"; do
        if [[ ! -f "${file}" ]]; then
            log_error "file not found: ${file}"
            exit "${EXIT_ENV}"
        fi
    done

    FILES=("${REST_ARGS[@]}")
}

run_actionlint() {
    if [[ "${RUN_ACTIONLINT}" -eq 0 ]]; then
        record_skip actionlint "disabled by --no-actionlint"
        return 0
    fi

    if ! command -v actionlint >/dev/null 2>&1; then
        HAS_INCOMPLETE=1
        record_unavailable actionlint "not installed"
        log_warning "install actionlint for static validation: https://github.com/rhysd/actionlint"
        return 0
    fi

    local output=""
    local status=0
    output="$(actionlint -oneline "${FILES[@]}" 2>&1)" || status=$?

    case "${status}" in
        0)
            record_pass actionlint "${#FILES[@]} file(s)"
            ;;
        1)
            HAS_FAILURE=1
            record_fail actionlint "workflow problems found"
            printf '%s\n' "${output}"
            ;;
        *)
            HAS_INCOMPLETE=1
            record_error actionlint "exited with status ${status}"
            printf '%s\n' "${output}"
            ;;
    esac
}

run_zizmor() {
    if [[ "${RUN_ZIZMOR}" -eq 0 ]]; then
        return 0
    fi

    if ! command -v zizmor >/dev/null 2>&1; then
        HAS_INCOMPLETE=1
        record_unavailable zizmor "not installed"
        log_warning "install zizmor for security analysis: https://github.com/zizmorcore/zizmor"
        return 0
    fi

    local output=""
    local status=0
    output="$(zizmor --offline --format=plain --no-progress "${FILES[@]}" 2>&1)" || status=$?

    case "${status}" in
        0)
            record_pass zizmor "${#FILES[@]} file(s)"
            ;;
        11 | 12 | 13 | 14)
            HAS_FAILURE=1
            record_fail zizmor "security findings (exit ${status})"
            printf '%s\n' "${output}"
            ;;
        *)
            HAS_INCOMPLETE=1
            record_error zizmor "exited with status ${status}"
            printf '%s\n' "${output}"
            ;;
    esac
}

summarize() {
    if [[ "${HAS_FAILURE}" -eq 1 ]]; then
        printf '[verify] result: FAIL\n'
        exit "${EXIT_FAIL}"
    fi

    if [[ "${HAS_INCOMPLETE}" -eq 1 ]]; then
        printf '[verify] result: INCOMPLETE\n'
        exit "${EXIT_ENV}"
    fi

    printf '[verify] result: PASS\n'
    exit "${EXIT_PASS}"
}

main() {
    require_command getopt

    parse_args "${@}"

    if [[ "${RUN_ACTIONLINT}" -eq 0 && "${RUN_ZIZMOR}" -eq 0 ]]; then
        log_error "no checks selected; enable actionlint or pass --security"
        exit "${EXIT_ENV}"
    fi

    resolve_files

    run_actionlint
    run_zizmor

    summarize
}

main "${@}"
