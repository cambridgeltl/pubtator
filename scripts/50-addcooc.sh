#!/bin/bash

# Add co-occurrence relations to data.

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPTNAME=$(basename "$0")

DATADIR="$SCRIPTDIR/../data/converted"
STATUSDIR="$SCRIPTDIR/../data/status"

set -eu

for d in $(find "$DATADIR" -mindepth 1 -maxdepth 1 -type d); do
    b=$(basename "$d")
    s="$STATUSDIR/$b.log"
    if [ -e "$s" ] && grep -qF "Done $SCRIPTNAME" "$s"; then
	echo "$SCRIPTNAME done for $b ($s), skipping ..." >&2
    else
	echo "Adding cooccurrence relations to $d ..." >&2
	python "$SCRIPTDIR/../tools/addcoocrelations.py" -r "$d"
	echo "Done adding cooccurrence relations to $d" >&2
	echo "Done $SCRIPTNAME" >> "$s"
    fi
done
