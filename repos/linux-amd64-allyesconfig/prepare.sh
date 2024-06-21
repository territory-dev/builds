#!/bin/bash
set -xeuo pipefail

source /var/lib/venv/bin/activate
eval $( fakecc install )
export FAKECC_SOCK=/tmp/fakecc.sock
export FAKECC_PASS=tmp,null  # pass-through compiler probes
export FAKECC_PASS_REC='*'
fakecc start

make CC='clang' ${TT_CONFIG_TARGET:-defconfig}

make -j${CORES:-8} CC='clang' prepare

unset FAKECC_PASS_REC
export FAKECC_NOOP_PROGS=ar,ld,objcopy,objtool
make -j${CORES:-8} --ignore-errors CC='clang' || :

fakecc dump compile_commands.json
fakecc stop
