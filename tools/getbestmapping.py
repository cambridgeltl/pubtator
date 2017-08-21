#!/usr/bin/env python

# Get most frequent from inverted mappings.

from __future__ import print_function

import sys

from common import json_load, pretty_dumps


def process(fn):
    with open(fn) as f:
        mappings = json_load(f)
    best = {}
    for s, ic in mappings.iteritems():
        best[s] = sorted(ic.items(), key=lambda kv: -kv[1])[0][0]
    print(pretty_dumps(best))


def main(argv):
    for fn in argv[1:]:
        process(fn)


if __name__ == '__main__':
    sys.exit(main(sys.argv))
