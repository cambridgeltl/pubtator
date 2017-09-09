#!/usr/bin/env python

import sys
import logging

from logging import warn

try:
    import ujson as json
except ImportError:
    warn('ujson not found, falling back to (slower) default json')
    import json


logging.basicConfig()
logger = logging.getLogger('common')
debug, info, warn, error = logger.debug, logger.info, logger.warn, logger.error


json_load = json.load

json_loads = json.loads


def set_log_level(level):
    logger.setLevel(logging.INFO)


def pretty_dump(obj, out=sys.stdout):
    return json.dump(obj, out, sort_keys=True, indent=2) #, separators=(',', ': '))


def pretty_dumps(obj):
    return json.dumps(obj, sort_keys=True, indent=2) #, separators=(',', ': '))


def read_pubyears(fn):
    """Read publication year data in PMID<TAB>YEAR format, return dict."""
    pubyear = {}
    with open(fn) as f:
        for ln, l in enumerate(f, start=1):
            try:
                pmid, year = l.split()
                year = int(year)
            except:
                raise ValueError('Expected PMID<TAB>YEAR in {}, got {}'.format(
                    fn, l))
            if pmid in pubyear:
                if pubyear[pmid] == year:    # harmless dup
                    debug('Duplicate PMID {} on line {} in {}'.format(
                        pmid, ln, fn))
                else:
                    warn('Conflicting year for {} on line {} in {}: {} vs {}'.\
                         format(pmid, ln, fn, pubyear[pmid], year))
                    year = min(year, pubyear[pmid])    # use earliest
            pubyear[pmid] = year
            if ln % 1000000 == 0:
                info('Read {} pubyears ...'.format(ln))
    info('Finished reading pubyears for {} PMIDs ({} lines)'.format(
        len(pubyear), ln))
    return pubyear
