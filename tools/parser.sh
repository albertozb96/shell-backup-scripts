#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

show_help()
{
    # Display Help
    echo "Usage: $(basename $0) [options]"
    echo "ADD A DESCRIPTION AT THE END"
    echo
    echo "Options:"
    echo "  -h, --help        Print this help."
    echo "  -l, --log-file    Uses LOG FILE instead stdout."
    echo
    echo "Exit status:"
    echo " 0  if OK"
    echo " 1  if runtime error"
    echo " 2  if invalid options"
}

show_error()
{
    echo "$(basename $0): invalid option."
    echo "Try '$(basename $0) --help' for more information."
}

OPTS=$(getopt -o hl -l help,log-file -- "$@" 2>/dev/null) || {
    show_error >&2
    exit 2
}
#if [ $? -ne 0 ]; then
#    echo "$(basename $0): invalid option." >&2
#    echo "Try '$(basename $0) --help' for more information." >&2
#    exit 2
#fi

eval set -- "$OPTS"

LOG_SAVED=false

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -l|--log-file)
            LOG_SAVED=true
            shift
            ;;
        --)
            shift
            ;;
        *)
            show_error >&2
            #echo "$(basename $0): invalid option." >&2
            #echo "Try '$(basename $0) --help' for more information." >&2
            exit 2
            ;;
    esac
done

if $LOG_SAVED; then
    echo "Script running with logs"
else
    echo "Script running without logs"
fi
