#!/bin/bash
set -euo pipefail -x

case $(arch) in
    aarch64) goarch=arm64;;
    x86_64)  goarch=amd64;;
    *) echo "unsupported architecture: $(arch)"; exit 1;;
esac

wget https://go.dev/dl/go1.23.2.linux-${goarch}.tar.gz -O /tmp/go.tar.gz
tar -C /home/territory -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz
