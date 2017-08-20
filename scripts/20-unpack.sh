#!/bin/bash

# Unpack source data.

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DATADIR="$SCRIPTDIR/../data/original-data"

for f in $(find "$DATADIR" -maxdepth 1 -name '*.gz'); do
    echo "Unpacking $f ..." >&2
    gunzip "$f"
    echo "Done unpacking $f" >&2
done
