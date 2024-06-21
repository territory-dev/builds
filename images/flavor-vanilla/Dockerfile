FROM debian:bookworm
WORKDIR /usr/src/territory

RUN useradd -m -d /home/territory -s /bin/bash -g users -r -u 2000 territory

RUN --mount=type=cache,target=/var/cache/apt \
  apt-get update && \
  apt-get install -y \
    wget \
    ;

RUN --mount=type=cache,target=/var/cache/apt \
  wget -qO /etc/apt/trusted.gpg.d/apt.llvm.org.asc https://apt.llvm.org/llvm-snapshot.gpg.key && \
  echo 'deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-18 main' >> /etc/apt/sources.list.d/llvm18.list && \
  apt-get update && \
  apt-get install -y clang-18 lld-18 && \
  ln -s /usr/bin/clang-18 /usr/bin/clang && \
  ln -s /usr/bin/clang-18 /usr/bin/clang++
ENV CLANG_RESOURCE_DIR "/usr/lib/clang/18"
ENV LIBCLANG_PATH "/usr/lib/llvm-18/lib"
