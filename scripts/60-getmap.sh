#!/bin/bash

# Get string to ID mappings from data.

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPTNAME=$(basename "$0")

INDIR="$SCRIPTDIR/../data/converted"
OUTDIR="$SCRIPTDIR/../data/mappings"

set -eu

for d in $(find "$INDIR" -mindepth 1 -maxdepth 1 -type d); do
    b=$(basename "$d")
    o="$OUTDIR/$b/str-id-map.json"
    if [[ -s "$o" && "$o" -nt "$d" ]]; then
	echo "Newer $o exists, skipping ..." >&2
    else
	mkdir -p $(dirname "$o")
	echo "Extracting string-id map from $d to $o ..." >&2	
	python "$SCRIPTDIR/../tools/getmappings.py" -r "$d" > "$o"
	echo "Done extracting string-id map from $d to $o ..." >&2	
    fi
done
