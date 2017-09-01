#!/bin/bash

# Merge PubTator and other annotations

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPTNAME=$(basename "$0")

DATADIR="$SCRIPTDIR/../data/converted"
STATUSDIR="$SCRIPTDIR/../data/status"
MERGEDIRS="
$SCRIPTDIR/../../hoc_annotations
"

set -eu

count=0
for m in $MERGEDIRS; do
    if [ ! -d "$m" ]; then
	cat <<EOF >&2
ERROR: $m is not a directory

Annotation merge expects Web Annotation JSON-LD annotations to be found
in the following directories:

    $MERGEDIRS

Edit $0 to change these locations.
EOF
	exit 1
    fi
    count=$((count+1))
done

if [[ $count -eq 0 ]]; then
    cat <<EOF >&2
Warning: no directories to merge in "$MERGEDIRS", exiting $0 without changes.
EOF
    exit 1
fi

for d in $(find "$DATADIR" -depth 1 -type d); do
    b=$(basename "$d")
    s="$STATUSDIR/$b.log"
    if [ -e "$s" ] && egrep -qF "Done $SCRIPTNAME" "$s"; then
	echo "$SCRIPTNAME done for $b ($s), skipping ..." >&2
    else
	echo "Merging annotations in $d with $MERGEDIRS ..." >&2
	python "$SCRIPTDIR/../tools/mergeannotations.py" -v -r -f -o "$d" "$d" $MERGEDIRS
	echo "Done merging annotations in $d with $MERGEDIRS" >&2
	echo "Done $SCRIPTNAME" >> "$s"
    fi
done
