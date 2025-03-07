#!/bin/bash
set -euo pipefail

IMAGE_REPO=europe-central2-docker.pkg.dev/territory-public-images/flavors
BUILD_SHA=
PUSH=
BUILD_OPTS=
TAG=main
WHAT=

while [ "x${1:-}" != x ]
do
    case "$1" in
        --repo)
            shift 1
            IMAGE_REPO="$1"
            ;;
        --tag)
            shift 1
            TAG="$1"
            ;;
        --what)
            shift 1
            WHAT="$1"
            ;;
        --build-sha)
            shift 1
            BUILD_SHA="$1"
            ;;
        --push)
            PUSH="--push"
            ;;
        --platform)
            shift 1
            BUILD_OPTS="--platform $1 $BUILD_OPTS"
            ;;
        --no-cache)
            BUILD_OPTS="--no-cache $BUILD_OPTS"
            ;;
        *)
            echo "bad argument: $1"
            exit 1
            ;;
    esac
    shift 1
done

that() {
    THAT="$1"
    shift 1

    if [ x$WHAT = x ] || [ x$THAT = x$WHAT ]
    then
        $@
    fi
}

PREFIX=
if [ x != x$IMAGE_REPO ]
then
    PREFIX="$IMAGE_REPO/"
fi

that vanilla docker buildx build \
    $BUILD_OPTS \
    --pull \
    -f images/flavor-vanilla/Dockerfile \
    -t ${PREFIX}vanilla:$TAG \
    .

for flavor in llvm godot linux nginx cpython go python
do
    that $flavor docker buildx build $PUSH \
        $BUILD_OPTS \
        --build-arg "VANILLA_IMAGE=${PREFIX}vanilla:${TAG}" \
        -f images/flavor-${flavor}/Dockerfile \
        -t ${PREFIX}${flavor}:${TAG} \
        .
done
