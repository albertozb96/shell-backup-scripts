#!/bin/bash

"${HOME}/shell-backup-scripts/main/daily-snapshot.sh" # && "${HOME}/shell-backup-scripts/main/purge-snapshots.sh" >> "${HOME}/Snapshots/purge.log"
"${HOME}/shell-backup-scripts/main/daily-snapshot-support.sh" # && "${HOME}/shell-backup-scripts/main/purge-snapshots-support.sh" >> "${HOME}/Snapshots-Support/purge.log"
