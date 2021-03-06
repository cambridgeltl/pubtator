#!/bin/bash

# Map IDs in data.

set -eu

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPTNAME=$(basename "$0")

UIDREPOURL="https://github.com/cambridgeltl/uniprotidmap"
UIDREPOGIT="git@github.com:cambridgeltl/uniprotidmap.git"
UIDREPONAME="uniprotidmap"

DATADIR="$SCRIPTDIR/../data/converted"
STATUSDIR="$SCRIPTDIR/../data/status"
INITMAP="$SCRIPTDIR/../data/idmappings/initial-idmapping.dat"
IDMAP="$SCRIPTDIR/../../uniprotidmap/NCBIGENE-pr-idmapping.dat"

if [ ! -f "$IDMAP" ]; then
    cat <<EOF >&2
ERROR: "$IDMAP" not found

ID mapping requires data generated by tools found in the repository
$UIDREPOURL. Try the following:

    cd ..
    git clone $UIDREPOGIT
    ./$UIDREPONAME/REBUILD-DATA.sh
    cd -

EOF
    exit 1
fi

for d in $(find "$DATADIR" -mindepth 1 -maxdepth 1 -type d); do
    b=$(basename "$d")
    s="$STATUSDIR/$b.log"
    idmaps="$INITMAP,$IDMAP"
    if [ -e "$s" ] && grep -qF "Done $SCRIPTNAME" "$s"; then
	echo "$SCRIPTNAME done for $b ($s), skipping ..." >&2
    else
	echo "Mapping IDs in $d with $idmaps ..." >&2
	python "$SCRIPTDIR/../tools/mapids.py" -r -v "$idmaps" "$d"
	echo "Done mapping IDs in $d with $idmaps" >&2
	echo "Done $SCRIPTNAME" >> "$s"
    fi
done
