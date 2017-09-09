#!/bin/bash

# Convert data to JSON-LD format.

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPTNAME=$(basename "$0")

INDIR="$SCRIPTDIR/../data/original-data"
OUTDIR="$SCRIPTDIR/../data/converted"
STATUSDIR="$SCRIPTDIR/../data/status"

set -eu

mkdir -p "$STATUSDIR"

for f in $(find "$INDIR" -maxdepth 1 -name '*.pubtator'); do
    b=$(basename "$f" .pubtator)
    o="$OUTDIR/${b}"
    s="$STATUSDIR/$b.log"
    if [ -e "$o" ]; then
	echo "$o exists, skipping conversion." >&2
    else
	mkdir -p "$o"
	echo "Converting data from $f to $o ..." >&2
	python "$SCRIPTDIR/../convertpubtator.py" \
	       -f wa-jsonld -o "$o" -s -ss -v "$f"
	echo "Done converting data from $f to $o" >&2
	echo "Done $SCRIPTNAME" > "$s"
    fi
done
