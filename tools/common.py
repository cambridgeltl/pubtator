#!/usr/bin/env python

import sys

from logging import warn

try:
    import ujson as json
except ImportError:
    warn('ujson not found, falling back to (slower) default json')
    import json


json_load = json.load

json_loads = json.loads

def pretty_dump(obj, out=sys.stdout):
    return json.dump(obj, out, sort_keys=True, indent=2) #, separators=(',', ': '))

def pretty_dumps(obj):
    return json.dumps(obj, sort_keys=True, indent=2) #, separators=(',', ': '))
