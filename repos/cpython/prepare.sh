#!/bin/bash
set -xeuo pipefail

export CC="clang"
export CCX="clang++"

./configure

source /var/lib/venv/bin/activate
export FAKECC_SOCK=/tmp/fakecc.sock
fakecc run make -j${CORES:-8} --ignore-errors || :

territory upload --tarball
