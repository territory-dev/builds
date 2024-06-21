FROM vanilla

RUN --mount=type=cache,target=/var/cache/apt \
  apt-get update && \
  apt-get install -y \
    build-essential \
    scons pkg-config libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev libglu-dev \
    libasound2-dev libpulse-dev libudev-dev libxi-dev libxrandr-dev \
    ;
