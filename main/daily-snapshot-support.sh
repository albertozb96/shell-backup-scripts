#!/bin/bash

# Script to perform incremental backups using rsync

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
    echo "  -v, --verbose     Show output in stdout."
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

OPTS=$(getopt -o lv -l help,verbose -- "$@" 2>/dev/null) || {
    show_error >&2
    exit 2
}

eval set -- "$OPTS"

VERBOSE=false

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --)
            shift
            ;;
        *)
            show_error >&2
            exit 2
            ;;
    esac
done

# %V = CW (Week)
# %G = CW Year, %g = Short CW Year
# %Y = Year, %y = Short Year

readonly DATETIME="$(date '+%gCW%V-%Y%m%d')"
readonly SOURCE_DIR="${HOME}/Syncthing"
readonly SNAPSHOT_DIR="${HOME}/Snapshots-Support"

cd "$SNAPSHOT_DIR" || exit 1

readonly FREE_SPACE=$(df --output=avail /dev/sda1 | tail -1)
readonly FREE_SPACE_GB=$(expr "$FREE_SPACE" / 1024 / 1024)
readonly FREE_SPACE_LIMIT=20

if [ "$FREE_SPACE_GB" -lt "$FREE_SPACE_LIMIT" ]; then
    if [ "$VERBOSE" = true ]; then
        echo "${DATETIME: -8}" >&2
        echo "$(basename $0): Less than ${FREE_SPACE_LIMIT}GB, aborting" >&2
    fi
    echo "${DATETIME: -8}" >> "${SNAPSHOT_DIR}/error.log"
    echo "$(basename $0): Less than ${FREE_SPACE_LIMIT}GB, aborting" >> "${SNAPSHOT_DIR}/error.log"
    exit 1
fi

readonly SNAPSHOT_NEW="Snapshot_${DATETIME}";
rm -rf "$SNAPSHOT_NEW" 2> /dev/null || true
readonly SNAPSHOT_PREV=$(find . -maxdepth 1 -type d -printf "%f\n" | grep -E '^Snapshot_[0-9]{2}CW[0-9]{2}-[0-9]{8}$' | sort | tail -n 1)

if [ "$VERBOSE" = true ]; then
    rsync -av --delete \
        --link-dest "$(realpath $SNAPSHOT_PREV)" \
        --exclude=".stversion" \
        --exclude=".stfolder" \
        --exclude="Backup" \
        --exclude="Docs" \
        "${SOURCE_DIR}/" \
        "${SNAPSHOT_NEW}" | tee "${SNAPSHOT_DIR}/rsync_${DATETIME: -8}.log"
else
    rsync -av --delete \
        --link-dest "$(realpath $SNAPSHOT_PREV)" \
        --exclude=".stversion" \
        --exclude=".stfolder" \
        --exclude="Backup" \
        --exclude="Docs" \
        "${SOURCE_DIR}/" \
        "${SNAPSHOT_NEW}" > "${SNAPSHOT_DIR}/rsync_${DATETIME: -8}.log"
fi

mv "${SNAPSHOT_DIR}/rsync_${DATETIME: -8}.log" "${SNAPSHOT_NEW}"

if diff -rq --exclude=diffs_*.log --exclude=rsync_*.log "${SNAPSHOT_PREV}" "${SNAPSHOT_NEW}" > /dev/null 2>&1; then
    if [ "$VERBOSE" = true ]; then
        echo
        echo "No differences between ${SNAPSHOT_PREV} and ${SNAPSHOT_NEW}" | \
            tee "${SNAPSHOT_DIR}/diffs_${DATETIME: -8}.log"
    else
        echo "No differences between ${SNAPSHOT_PREV} and ${SNAPSHOT_NEW}" > \
            "${SNAPSHOT_DIR}/diffs_${DATETIME: -8}.log"
    fi
else
    if [ "$VERBOSE" = true ]; then
        echo -e "\nDifferences between ${SNAPSHOT_PREV} and ${SNAPSHOT_NEW} saved in ${SNAPSHOT_NEW}/}/diffs_${DATETIME}.log"
    fi
    echo -e "Differences between ${SNAPSHOT_PREV} and ${SNAPSHOT_NEW}\n" > \
        "${SNAPSHOT_DIR}/diffs_${DATETIME: -8}.log"
    diff -rq --exclude=diffs_*.log --exclude=rsync_*.log "${SNAPSHOT_PREV}" "${SNAPSHOT_NEW}" >> \
        "${SNAPSHOT_DIR}/diffs_${DATETIME: -8}.log" || true
fi

mv "${SNAPSHOT_DIR}/diffs_${DATETIME: -8}.log" "${SNAPSHOT_NEW}"
