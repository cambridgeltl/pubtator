#!/bin/bash

# Invert string to ID mappings into ID to string mappings.

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPTNAME=$(basename "$0")

DATADIR="$SCRIPTDIR/../data/mappings"

set -eu

for f in $(find "$DATADIR" -name 'str-id-map.json'); do
    o=$(dirname "$f")"/id-str-map.json"
    if [[ -s "$o" && "$o" -nt "$f" ]]; then
	echo "Newer $o exists, skipping ..." >&2
    else
	echo "Inverting string-id map from $f to $o ..." >&2	
	python "$SCRIPTDIR/../tools/invertmappings.py" "$f" > "$o"
	echo "Done inverting string-id map from $f to $o ..." >&2	
    fi
done
