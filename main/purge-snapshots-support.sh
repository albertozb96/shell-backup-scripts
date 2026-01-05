#!/bin/bash

# Script to delete innecesaries backups

set -o errexit
set -o nounset
set -o pipefail

readonly SNAPSHOT_DIR="${HOME}/Snapshots-Support"
readonly MAX_DELETE=3
readonly YEARS_SNAPSHOTS=1
readonly DATE_DAYS_AGO=$(date -d "14 days ago" '+%Y%m%d')
readonly DATE_YEARS_AGO=$(date -d "${YEARS_SNAPSHOTS} years ago" '+%Y%m%d')
delete=0

cd "$SNAPSHOT_DIR" || exit

echo "$(basename $0): $(date '+%Y-%m-%d')"

for dir in Snapshot_*; do
    if [ "$delete" -lt "$MAX_DELETE" ] && [ -d "$dir" ]; then
        case "$dir" in
            Snapshot_??CW??)
                dirCw=${dir: -2}
                dirYear=20${dir: -6:2}
                if [ "$dirYear" -lt $(date -d "$DATE_YEARS_AGO" +%Y) ] || \
                    ( [ "$dirYear" -eq $(date -d "$DATE_YEARS_AGO" +%Y) ] && \
                    [ "$dirCw" -lt $(date -d "$DATE_YEARS_AGO" +%V) ] ); then
                    rm -rf "$dir"
                    echo "$dir Deleted."
                    delete=$(expr "$delete" + 1)
                fi
                ;;
            Snapshot_??CW??-????????)
                dirDate=${dir: -8}
                if [ "$dirDate" -le "$DATE_DAYS_AGO" ]; then
                    if [ $(date -d "$dirDate" +%u) -ne 7 ]; then
                        rm -rf "$dir"
                        echo "$dir Deleted."
						delete=$(expr "$delete" + 1)
                    else
                        SNAPSHOT_NEW="${dir:0:15}"
						SNAPSHOT_PREV=$(find . -maxdepth 1 -type d -printf "%f\n" \
                            | grep -E '^Snapshot_[0-9]{2}CW[0-9]{2}$' | sort | tail -n 1 ) || true
                        mv "$dir" "${dir:0:15}"
                        rm "${SNAPSHOT_NEW}/diffs_${dir: -8}.log" || true

                        if [ "$SNAPSHOT_PREV" != "" ]; then
                            if diff -rq --exclude=diffs_*.log --exclude=rsync_*.log "${SNAPSHOT_PREV}" "${SNAPSHOT_NEW}" > /dev/null 2>&1; then
                                echo "No differences between ${SNAPSHOT_PREV} and ${SNAPSHOT_NEW}" > \
                                    "${SNAPSHOT_DIR}/diffs_${SNAPSHOT_NEW: -8}.log"
                            else
                                echo -e "Differences between ${SNAPSHOT_PREV} and ${SNAPSHOT_NEW}\n" > \
                                    "${SNAPSHOT_DIR}/diffs_${SNAPSHOT_NEW: -6}.log"
                                diff -rq --exclude=diffs_*.log --exclude=rsync_*.log "${SNAPSHOT_PREV}" "${SNAPSHOT_NEW}" >> \
                                    "${SNAPSHOT_DIR}/diffs_${SNAPSHOT_NEW: -6}.log" || true
                            fi
                            mv "${SNAPSHOT_DIR}/diffs_${SNAPSHOT_NEW: -6}.log" "${SNAPSHOT_NEW}"
                        fi

                        echo "$dir moved to ${SNAPSHOT_NEW}."
                    fi
                fi
                ;;
        esac
    else
        echo "Max number of folders ($MAX_DELETE) deleted. Script finished."
		echo
	exit
    fi
done

echo "Nothing more to do. Script finished."
echo
