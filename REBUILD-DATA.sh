#!/bin/bash

# Rebuild data from sources.

# This is a top-level driver script that runs scripts named
# [0-9][0-9]*.sh in the subdirectory scripts/ in alphanumeric order
# (lowest numbers first). Outputs "ERROR" and terminates immediately
# if any script fails.


set -eu

SCRIPTNAME=$(basename "$0")
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cat <<EOF >&2
##########
########## STARTING: $SCRIPTNAME at $(date)
##########
EOF

function error {
    set +o errtrace
    set +o xtrace
    cat <<EOF >&2
##########
########## ERROR: $SCRIPTNAME failed at $(date)
##########
EOF
}
trap error ERR

for script in "$SCRIPTDIR/scripts/"[0-9][0-9]*.sh; do
    echo $'\n'"Running $script ..."$'\n' >&2
    time "$script"
    echo $'\n'"Completed $script"$'\n' >&2
done

cat <<EOF >&2
##########
########## DONE: $SCRIPTNAME completed succesfully at $(date)
##########
EOF
