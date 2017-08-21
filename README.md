# PubTator format conversion

Conver PubTator format to other formats.

## Quickstart

To download PubTator source data and generate a Web Annotation JSON-LD
version of the data, run

    ./REBUILD-DATA.sh

If successful, this process generates a `.txt` and a `.jsonld` file
for each PubMed document in the data in a subdirectory of
`data/complete-converted` and outputs "DONE" on completion.

Note that for the complete PubTator dataset, this process generates
over 50 million files that require over 200G of disk space and is
likely to require at least 24 hours to complete.

## Requirements

- Unix shell and standard tools (e.g. wget)
- Python 2.7

## Troubleshooting

- `idmap` step fails with error `idmapping.dat not found`: this step
  requires that a copy of https://github.com/cambridgeltl/uniprotidmap
  is found in a sibling directory (`../uniprotidmap`) and that the script
  `./REBUILD-DATA.sh` has been successfully run there. This can be done
  by running

      cd ..
      git clone git@github.com:cambridgeltl/uniprotidmap.git
      ./uniprotidmap/REBUILD-DATA.sh
      cd -

  in the root directory of this repository.
