#!/bin/bash

# Download source data.

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SOURCES="
ftp://ftp.ncbi.nlm.nih.gov/pub/lu/PubTator/bioconcepts2pubtator_offsets.sample
ftp://ftp.ncbi.nlm.nih.gov/pub/lu/PubTator/bioconcepts2pubtator_offsets.gz
"

DATADIR="$SCRIPTDIR/../data/original-data"

set -eu

mkdir -p "$DATADIR"

for url in $SOURCES; do
    bn=$(basename "$url")
    # rename
    if [[ "$bn" == "bioconcepts2pubtator_offsets.sample" ]]; then
	bn="sample.pubtator"
    elif [[ "$bn" == "bioconcepts2pubtator_offsets.gz" ]]; then
	bn="complete.pubtator.gz"
    fi
    un=${bn%.gz}
    if [ -e "$DATADIR/$bn" ]; then
	echo "$DATADIR/$bn exists, skipping download." >&2
    elif [ -e "$DATADIR/$un" ]; then
	echo "$DATADIR/$un exists, skipping download." >&2
    else
	echo "Downloading $url to $DATADIR/$bn ..." >&2
	wget -O "$DATADIR/$bn" "$url"
	echo "Done downloading $url to $DATADIR/$bn" >&2	
	echo "$bn downloaded on "$(date)" from $url" >> "$DATADIR/SOURCE"
    fi
done
