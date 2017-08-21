#!/usr/bin/env python

# Invert string to ID mapping to create ID to string mapping from the
# output of getmappings.py

from __future__ import print_function

import sys

from logging import warn
from common import json_load, pretty_dumps


def invert(mappings):
    inverted = {}
    for mention, mapping in mappings.iteritems():
        for id_, count in mapping.iteritems():
            if id_ not in inverted:
                inverted[id_] = {}
            assert mention not in inverted[id_]
            inverted[id_][mention] = count
    return inverted


def process(fn):
    with open(fn) as f:
        mappings = json_load(f)
    inverted = invert(mappings)
    print(pretty_dumps(inverted))


def main(argv):
    for fn in argv[1:]:
        process(fn)


if __name__ == '__main__':
    sys.exit(main(sys.argv))
