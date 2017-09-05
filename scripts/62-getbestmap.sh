#!/bin/bash

# Get best string mapping for ID.

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPTNAME=$(basename "$0")

DATADIR="$SCRIPTDIR/../data/mappings"

set -eu

for f in $(find "$DATADIR" -name 'id-str-map.json'); do
    o=$(dirname "$f")"/id-best-str-map.json"
    if [[ -s "$o" && "$o" -nt "$f" ]]; then
	echo "Newer $o exists, skipping ..." >&2
    else
	echo "Getting best string-id map from $f to $o ..." >&2	
	python "$SCRIPTDIR/../tools//getbestmapping.py" "$f" > "$o"
	echo "Done getting best string-id map from $f to $o ..." >&2	
    fi
done
