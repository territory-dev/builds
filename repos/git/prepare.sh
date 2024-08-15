#!/bin/bash
set -xeuo pipefail

source /var/lib/venv/bin/activate
export FAKECC_SOCK=/tmp/fakecc.sock
export FAKECC_PASS=tmp,null  # pass-through compiler probes
export FAKECC_NOOP_PROGS=ar,ld,objcopy,objtool
fakecc run make -j${CORES:-8} --ignore-errors CC='clang' || :

territory upload --tarball
