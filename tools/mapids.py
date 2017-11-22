#!/usr/bin/env python

# Modify "id" values in JSON data according to wrapping.

from __future__ import print_function

import os
import sys
import re
import logging

from collections import defaultdict
from logging import info, warn, error
from common import json_load, pretty_dump


logging.basicConfig()
logger = logging.getLogger('mapids')
debug, info, warn, error = logger.debug, logger.info, logger.warn, logger.error


class FormatError(Exception):
    pass


def argparser():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('-p', '--prefix', default=None,
                    help='Namespace prefix of IDs to map')
    ap.add_argument('-r', '--recurse', default=False, action='store_true',
                    help='Recurse into subdirectories')
    ap.add_argument('-s', '--suffix', default='.jsonld',
                    help='Suffix of files to process (with -r)')
    ap.add_argument('-v', '--verbose', default=False, action='store_true',
                    help='Verbose output')
    ap.add_argument('idmap', metavar='FILE[,FILE[...]]',
                    help='File(s) with ID mapping')
    ap.add_argument('files', metavar='FILE', nargs='+',
                    help='Files or directories to merge')
    return ap


def make_condition(condition):
    if not condition or not condition.strip():
        return None
    if condition.startswith('/') and condition.endswith('/'):
        # regular expression matching
        e = re.compile(condition[1:-1])
        return lambda t: e.search(t) is not None
    else:
        raise NotImplementedError(condition)


def read_mapping(fn):
    read = 0
    mapping = defaultdict(list)
    with open(fn) as f:
        for i, l in enumerate(f, start=1):
            l = l.rstrip('\n')
            f = l.split('\t')
            if len(f) == 3:
                id1, id_type, id2 = f
                condition, mapped_type = None, None
            elif len(f) == 4:
                id1, id_type, id2, condstr = f
                condition = make_condition(condstr)
                mapped_type = None
            elif len(f) == 5:
                id1, id_type, id2, condstr, mapped_type = f
                condition = make_condition(condstr)
            else:
                raise FormatError('expected 3 or 4 TAB-separated values, got {} on line {} in {}: {}'.format(len(f), i, fn, l))
            if (id_type, id2, condition, mapped_type) not in mapping[id1]:
                mapping[id1].append((id_type, id2, condition, mapped_type))
            read += 1
    info('Read {} from {}'.format(read, fn))
    return mapping


def map_id_single(id_, mapidx, mapping, options, text):
    if id_ not in mapping:
        map_id.stats['{}:missing'.format(mapidx)] += 1
        return id_, None
    else:
        mapped = []
        for id_type, m_id, condition, m_type in mapping[id_]:
            if condition is None or condition(text):
                mapped.append((m_id, m_type))
            else:
                map_id.stats['{}:filtered'.format(mapidx)] += 1
        if not mapped:
            return id_, None
        elif len(mapped) == 1:
            mapped = mapped[0]
        else:
            assert len(mapped) > 1
            map_id.stats['{}:multiple'.format(mapidx)] += 1
            warn('{} maps to multiple, arbitrarily using first: {}'.format(id_, ', '.join([m[0] for m in mapped])))
            mapped = mapped[0]    # TODO better resolution
        map_id.stats['{}:mapped'.format(mapidx)] += 1
        return mapped


def map_id(id_, mappings, options, text):
    if options.prefix:
        if not id_.startswith(options.prefix):
            return id_, None    # prefix filter
    mapped_type = None
    for idx, mapping in enumerate(mappings):
        id_, m_type = map_id_single(id_, idx, mapping, options, text)
        mapped_type = mapped_type if m_type is None else m_type
    return id_, mapped_type
map_id.stats = defaultdict(int)


def map_id_stats():
    return ', '.join('{} {}'.format(s, v)
                     for s, v in sorted(map_id.stats.items()))


def map_ids(data, mappings, options=None, objtext=None):
    if isinstance(data, list):
        for d in data:
            map_ids(d, mappings, options, objtext)
    elif isinstance(data, dict):
        if 'id' in data:
            m_id, m_type = map_id(data['id'], mappings, options, objtext)
            data['id'] = m_id
            if m_type is not None:
                data['type'] = m_type
        if 'text' in data:
            objtext = data['text']
        for k, v in data.iteritems():
            if isinstance(v, (list, dict)):
                map_ids(v, mappings, options, objtext)
    return data


def map_file_ids(fn, mappings, options=None):
    with open(fn) as f:
        data = json_load(f)
    map_ids(data, mappings, options)
    with open(fn, 'wt') as f:
        pretty_dump(data, f)


def map_files_ids(files, mappings, options, count=0, errors=0, recursed=False):
    for fn in files:
        _, ext = os.path.splitext(os.path.basename(fn))
        if os.path.isfile(fn) and recursed and ext != options.suffix:
            continue
        elif os.path.isfile(fn):
            try:
                map_file_ids(fn, mappings, options)
            except Exception, e:
                error('failed {}: {}'.format(fn, e))
                errors += 1
            count += 1
            if count % 100 == 0:
                info('Processed {} documents ...'.format(count))
        elif os.path.isdir(fn):
            if options.recurse:
                df = [os.path.join(fn, n) for n in os.listdir(fn)]
                count, errors = map_files_ids(df, mappings, options, count,
                                              errors, True)
            else:
                info('skipping directory {}'.format(fn))
    if not recursed:
        info('Done, processed {} documents ({} errors).'.format(count, errors))
    return count, errors


def main(argv):
    args = argparser().parse_args(argv[1:])
    if args.verbose:
        logger.setLevel(logging.INFO)

    mappings = []
    for mapfn in args.idmap.split(','):
        mappings.append(read_mapping(mapfn))

    map_files_ids(args.files, mappings, args)

    info(map_id_stats())
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
