#!/bin/bash
set -e

# Build multi-architecture PHP images
# Usage: ./build.sh [target] [--push]
#   target: base, dev, prod, testing, all (default: all)
#   --push: push to registry after building
#
# Environment variables:
#   REGISTRY     - Registry prefix (e.g., ghcr.io/user/repo/)
#   VERSION      - Version tag (default: latest)
#   PHP_VERSION  - PHP version for tag prefix (default: 8.3)

TARGET=${1:-all}
PUSH=${2:-}

# Validate target
if [[ ! "$TARGET" =~ ^(base|dev|prod|testing|all)$ ]]; then
    echo "Error: Invalid target '$TARGET'"
    echo "Valid targets: base, dev, prod, testing, all"
    exit 1
fi

REGISTRY=${REGISTRY:-""}
PHP_VERSION=${PHP_VERSION:-"8.4"}
VERSION=${VERSION:-"latest"}
TAG="${PHP_VERSION}-${VERSION}"

# Platform for multi-arch builds
PLATFORMS="linux/amd64,linux/arm64"

build_image() {
    local name=$1
    local dockerfile=$2
    local build_args=${3:-}

    local full_tag="${REGISTRY}php-fpm-${name}:${TAG}"

    echo "Building ${full_tag}..."

    if [ -n "$PUSH" ]; then
        docker buildx build \
            --platform "${PLATFORMS}" \
            --file "${dockerfile}" \
            ${build_args:+"$build_args"} \
            --tag "${full_tag}" \
            --push \
            .
    else
        docker build \
            --file "${dockerfile}" \
            ${build_args:+"$build_args"} \
            --tag "${full_tag}" \
            .
    fi
}

# Build base first (required by others)
if [ "$TARGET" = "base" ] || [ "$TARGET" = "all" ]; then
    build_image "base" "_docker/base/Dockerfile"
fi

# Build dev (requires base)
if [ "$TARGET" = "dev" ] || [ "$TARGET" = "all" ]; then
    build_image "dev" "_docker/dev/Dockerfile" "--build-arg BASE_IMAGE=${REGISTRY}php-fpm-base:${TAG}"
fi

# Build prod (requires base)
if [ "$TARGET" = "prod" ] || [ "$TARGET" = "all" ]; then
    build_image "prod" "_docker/prod/Dockerfile" "--build-arg BASE_IMAGE=${REGISTRY}php-fpm-base:${TAG}"
fi

# Build testing (requires dev)
if [ "$TARGET" = "testing" ] || [ "$TARGET" = "all" ]; then
    build_image "testing" "_docker/testing/Dockerfile" "--build-arg DEV_IMAGE=${REGISTRY}php-fpm-dev:${TAG}"
fi

echo "Done!"
