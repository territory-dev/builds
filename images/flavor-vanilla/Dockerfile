FROM debian:bookworm
WORKDIR /usr/src/territory

RUN useradd -m -d /home/territory -s /bin/bash -g users -r -u 2000 territory
ENV HOME=/home/territory

RUN --mount=type=cache,target=/var/cache/apt \
  apt-get update && \
  apt-get install -y \
    wget python3-venv python3-pip git \
    ;

RUN --mount=type=cache,target=/var/cache/apt \
  wget -qO /etc/apt/trusted.gpg.d/apt.llvm.org.asc https://apt.llvm.org/llvm-snapshot.gpg.key && \
  echo 'deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-18 main' >> /etc/apt/sources.list.d/llvm18.list && \
  apt-get update && \
  apt-get install -y clang-18 lld-18 && \
  ln -s /usr/bin/lld-18 /usr/bin/lld && \
  ln -s /usr/bin/clang-18 /usr/bin/clang && \
  ln -s /usr/bin/clang-18 /usr/bin/clang++
ENV CLANG_RESOURCE_DIR "/usr/lib/clang/18"
ENV LIBCLANG_PATH "/usr/lib/llvm-18/lib"

RUN \
  python3 -m venv /var/lib/venv &&\
  /var/lib/venv/bin/pip install territory
