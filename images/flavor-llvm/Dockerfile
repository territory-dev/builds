ARG VANILLA_IMAGE
FROM $VANILLA_IMAGE

RUN --mount=type=cache,target=/var/cache/apt \
  apt-get update && \
  apt-get install -y \
    build-essential \
    libc6-dev libgcc-12-dev libatomic1 libgcc-s1 libstdc++-12-dev  libstdc++6 \
    cmake ninja-build \
    ;
