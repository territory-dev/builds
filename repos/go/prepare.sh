#!/bin/bash
set -xeuo pipefail

REPO="$(pwd)"

cd src
export GOROOT_BOOTSTRAP=/home/territory/go
./make.bash --no-banner || :

unset GOROOT
unset GOPATH
unset GOCACHE
unset GOMODCACHE
export GOROOT=$REPO
export GOPATH=$REPO
export PATH="/home/territory/.venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$REPO/bin"

territory upload --tarball-only -l go --system
