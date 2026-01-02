#!/bin/bash

readonly SNAPSHOTS_DIR="${HOME}/Snapshots"
readonly MAX_DELETE=3
readonly YEARS_SNAPSHOTS=1
readonly DATE_28D_AGO=$(date -d "$TODAY -28 days" +%Y%m%d)
readonly DATE_YEAR_AGO=$(date -d "$TODAY -"$YEARS_SNAPSHOTS" year" +%Y%m%d)
delete=0

echo "Snapshot purge of $(date -d)"

cd "$SNAPSHOTS_DIR" || exit

for dir in Snapshot_*; do
    if [ "$delete" -lt "$MAX_DELETE" ]; then
        if [ -d "$dir" ] && [ "$dir" != "Snapshot_Latest" ]; then
            dirCwCheck=${dir: -4:2}
            if [ "$dirCwCheck" = "CW" ]; then
                dirCw=${dir: -2}
                dirYear=20${dir: -6:2}
                if [ "$dirYear" -lt $(date -d "$DATE_YEAR_AGO" +%Y) ] || \
                    ( [ "$dirYear" -eq $(date -d "$DATE_YEAR_AGO" +%Y) ] && \
                    [ "$dirCw" -lt $(date -d "$DATE_YEAR_AGO" +%V) ] ); then
                    rm -rf "$dir"
                    echo "$dir Deleted."
                fi
            else
                dirDate=${dir: -8}
                if [ "$dirDate" -le "$DATE_28D_AGO" ]; then
                    if [ $(date -d "$dirDate" +%u) -ne 7 ]; then
                        rm -rf "$dir"
                        echo "$dir Deleted."
			((delete++))
                    else
                        # Find previous backup when Sunday snapshot becomes permanent
			SNAPSHOT_PREV=$(find . -maxdepth 1 -type d -printf "%f\n" \
                            | grep -E "CW[0-9]{2}$" | sort | tail -n 1 )
                        # Make Sunday snapshot permanent
                        mv "$dir" "${dir:0:15}"
                        # Modify differences.txt
                        rm "${dir:0:15}/differences.txt" || true
                        diff -rq --exclude=differences.txt "${SNAPSHOT_PREV}" "${dir:0:15}" \
                            > "${SNAPSHOTS_DIR}/differences.txt" 2>&1 || true
                        mv "${SNAPSHOTS_DIR}/differences.txt" "${dir:0:15}"
                        # Print directory moved
                        echo "$dir moved to ${dir:0:15}."
                    fi
                fi
            fi
        fi
    else
        echo "Max number of folders ($MAX_DELETE) deleted. Script finished."
	exit
    fi
done

echo "Nothing more to do. Script finished."
