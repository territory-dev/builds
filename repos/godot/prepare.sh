#!/bin/bash
set -xeuo pipefail

scons platform=linuxbsd use_llvm=yes compiledb=yes

/var/lib/venv/bin/territory upload --tarball-only --system
