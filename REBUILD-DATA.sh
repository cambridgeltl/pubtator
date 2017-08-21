#!/bin/bash

# Rebuild data from sources.

set -eu

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for script in "$SCRIPTDIR/scripts/"[0-9][0-9]*.sh; do
    echo "Running $script ..." >&2
    time "$script"
    echo "Completed $script" >&2
    echo >&2
done

echo "DONE, "`basename $0`" completed succesfully."
