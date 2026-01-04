#!/bin/bash

"${HOME}/shell-backup-scripts/main/daily-snapshot.sh" -v && "${HOME}/shell-backup-scripts/main/purge-snapshots.sh" #>> "${HOME}/Snapshots/purge.log"
