FROM vanilla
RUN --mount=type=cache,target=/var/cache/apt \
  sed -i.bak 's/^Types: deb/Types: deb deb-src/g' /etc/apt/sources.list.d/debian.sources && \
  apt-get update && \
  apt-get install -y build-essential python3-venv python3-pip git && \
  apt-get build-dep -y python3

RUN \
  python3 -m venv /var/lib/venv &&\
  /var/lib/venv/bin/pip install -e git+https://github.com/territory-dev/fakecc.git#egg=fakecc
