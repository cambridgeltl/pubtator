#!/usr/bin/env python

# Get Web Annotation statistics from JSON-LD data.

from __future__ import print_function

import os
import sys
import json
import logging

from collections import defaultdict
from logging import info, warn, error

from webannotation import read_annotations


def argparser():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('-r', '--recurse', default=False, action='store_true',
                    help='Recurse into subdirectories')
    ap.add_argument('-s', '--suffix', default='.jsonld',
                    help='Suffix of files to process (with -r)')
    ap.add_argument('-v', '--verbose', default=False, action='store_true',
                    help='Verbose output')
    ap.add_argument('files', metavar='FILE', nargs='+',
                    help='Files or directories to merge')
    return ap


def process_file(fn, options, stats):
    try:
        annotations = read_annotations(fn)
    except Exception, e:
        error('failed to parse {}: {}'.format(fn, e))
        raise
    for a in annotations:
        stats['total'] += 1
        stats[type(a).__name__] += 1


def process(files, options, stats=None, recursed=False):
    if stats is None:
        stats = defaultdict(int)
    for fn in files:
        _, ext = os.path.splitext(os.path.basename(fn))
        if os.path.isfile(fn) and recursed and ext != options.suffix:
            continue
        elif os.path.isfile(fn):
            try:
                process_file(fn, options, stats)
            except Exception, e:
                logging.error('failed {}: {}'.format(fn, e))
                stats['errors'] += 1
            stats['files'] += 1
            if stats['files'] % 100 == 0:
                info('Read {} documents ...'.format(stats['files']))
        elif os.path.isdir(fn):
            if options.recurse:
                df = [os.path.join(fn, n) for n in os.listdir(fn)]
                stats = process(df, options, stats, True)
            else:
                info('skipping directory {}'.format(fn))
    if not recursed:
        info('Done, read {} documents ({} errors).'.format(
            stats['files'], stats['errors']))
    return stats


def write_stats(stats, out=sys.stdout):
    print('Done, processed {} files ({} errors)'.format(
        stats['files'], stats['errors']), file=out)
    print(file=out)
    for k, v in sorted(stats.items()):
        if k not in ('files', 'errors'):
            print('{:>10}\t{}'.format(v, k), file=out)


def main(argv):
    args = argparser().parse_args(argv[1:])
    if args.verbose:
        logging.basicConfig(level=logging.INFO)
    stats = process(args.files, args)
    write_stats(stats)
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
