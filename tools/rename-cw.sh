#!/bin/bash

readonly SNAPSHOTS_DIR="${HOME}/Snapshots"
cd "$SNAPSHOTS_DIR" || exit

for folder in Snapshot_*; do
    if [ -d "$folder" ]; then
        # Delete Snapshot_
        fDate=${folder#Snapshot_}
	# Delete %H%M%S
        fDate=${fDate%-*}

        # Calculate CW
        fCw=$(date -d "$fDate" +%V)
	fCwYear=$(date -d "$fDate" +%g)

	# New Name
        fNewName="Snapshot_${fCwYear}CW${fCw}-${fDate}"

        # Renombramos
        mv "$folder" "$fNewName"
        echo "Renamed: $folder -> $fNewName"
    fi
done
