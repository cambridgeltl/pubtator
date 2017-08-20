#!/bin/bash

# Add co-occurrence relations to data.

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DATADIR="$SCRIPTDIR/../data"

set -eu

for d in $(find "$DATADIR" -maxdepth 1 -name '*-converted' -type d); do
    echo "Adding cooccurrence relations to $d ..." >&2
    python "$SCRIPTDIR/../tools/addcoocrelations.py" -r "$d"
    echo "Done adding cooccurrence relations to $d" >&2
done
