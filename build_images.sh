#!/bin/bash
set -euo pipefail

IMAGE_REPO=
BUILD_SHA=
PUSH=
BUILD_OPTS=
TAG=
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
        *)
            echo "bad argument: $1"
            exit 1
            ;;
    esac
    shift 1
done

if [ "x${TAG:-}" = x ]
then
    echo "--tag unspecified"
    exit 1
fi

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
    IMAGE_PREFIX="$IMAGE_REPO/"
fi

that vanilla docker buildx build \
    $BUILD_OPTS \
    --pull \
    -f images/flavor-vanilla/Dockerfile \
    -t ${PREFIX}vanilla:$TAG \
    .

for flavor in llvm godot linux nginx
do
    that $flavor docker buildx build $PUSH \
        $BUILD_OPTS \
        --build-context "vanilla=docker-image://${PREFIX}vanilla:$TAG" \
        -f images/flavor-$flavor/Dockerfile \
        -t ${PREFIX}flavor-$flavor:$TAG \
        .
done
