#!/bin/bash

# Convert data to JSON-LD format.

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

INDIR="$SCRIPTDIR/../data/original-data"
DATADIR="$SCRIPTDIR/../data"

set -eu

for f in $(find "$INDIR" -maxdepth 1 -name '*.pubtator'); do
    b=$(basename "$f" .pubtator)
    o="$DATADIR/${b}-converted"
    if [ -e "$o" ]; then
	echo "$o exists, skipping conversion." >&2
    else
	mkdir -p "$o"
	echo "Converting data from $f to $o ..." >&2
	python "$SCRIPTDIR/../convertpubtator.py" -f wa-jsonld -o "$o" -s -ss "$f"
	echo "Done converting data from $f to $o" >&2
    fi
done
