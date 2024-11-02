#!/bin/bash
set -xeuo pipefail

export GOGC=2000
make
territory upload --tarball-only -l go --system
