#!/bin/bash
set -xeuo pipefail

cmake \
    -DCMAKE_BUILD_TYPE=Release      \
    -DCMAKE_C_COMPILER=clang-18     \
    -DCMAKE_CXX_COMPILER=clang++-18 \
    -DLLVM_ENABLE_PROJECTS=all      \
    -DLLVM_ENABLE_RUNTIMES=all      \
    -DLLVM_USE_LINKER=lld           \
    -DLLVM_APPEND_VC_REV=OFF        \
    -G Ninja                        \
    -S llvm


ninja -t targets |  awk -F: '/(\.inc|\.h):/ { print $1 }' | xargs ninja


/var/lib/venv/bin/territory upload --tarball
