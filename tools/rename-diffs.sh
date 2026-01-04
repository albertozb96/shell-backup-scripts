#!/bin/bash

cd "${HOME}/Snapshots"

for dir in Snapshot_*; do
    # $dir takes each name that start with "Snapshot_"
    if [ -d "$dir" ]; then    # Verify that it is a directory
        mv "$dir/differences.txt" "$dir/diffs_${dir: -8}.log"
    fi
done
