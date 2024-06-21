FROM vanilla
RUN --mount=type=cache,target=/var/cache/apt \
  apt-get update && \
  apt-get install -y \
    build-essential bc kmod cpio flex libncurses5-dev libelf-dev libssl-dev dwarves bison \
    libc6-dev libgcc-12-dev libatomic1 libgcc-s1 libstdc++-12-dev  libstdc++6 \
    python3-venv python3-pip git \
    ;

RUN \
  python3 -m venv /var/lib/venv &&\
  /var/lib/venv/bin/pip install -e git+https://github.com/territory-dev/fakecc.git#egg=fakecc
