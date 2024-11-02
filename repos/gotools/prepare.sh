#!/bin/bash
set -xeuo pipefail

export GOGC=2000
export GOCACHE=$GOROOT/cache/build
export GOMODCACHE=$GOROOT/cache/mod
export GOPATH=$GOROOT

for mod in $( find . -name '*.mod' )
do
    echo "downloading dependencies for $mod"
    cd $(dirname $mod)
    go mod download
    cd -
done
territory upload --tarball-only -l go --system
