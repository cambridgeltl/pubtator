#!/bin/bash

# Add co-occurrence relations to data.

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DATADIR="$SCRIPTDIR/../data/converted"

set -eu

for d in $(find "$DATADIR" -depth 1 -type d); do
    echo "Adding cooccurrence relations to $d ..." >&2
    python "$SCRIPTDIR/../tools/addcoocrelations.py" -r "$d"
    echo "Done adding cooccurrence relations to $d" >&2
done
