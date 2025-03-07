FROM ubuntu:noble AS base

RUN apt-get update && \
    apt-get install -y \
        ca-certificates build-essential git wget rsync python3-pip python3-venv

RUN groupadd -g 2000 territory
RUN useradd -m -d /home/territory -s /bin/bash -g users -r -u 2000 territory
ENV HOME=/home/territory
USER territory:territory

RUN \
    --mount=type=secret,id=pypirc,destination=$HOME/.config/pip/pip.conf,uid=2000,gid=2000 \
    python3 -m venv $HOME/.venv && \
    $HOME/.venv/bin/pip install \
        territory
ENV PATH=$HOME/.venv/bin:$PATH
