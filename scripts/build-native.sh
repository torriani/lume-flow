#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p build
# LUME_SDKROOT is a build-only override for machines with mismatched CLT/SDK versions.
lume_sdk="${LUME_SDKROOT:-$(xcrun --show-sdk-path)}"
lume_arch="${LUME_ARCH:-arm64}"
[ "$lume_arch" != x64 ] || lume_arch=x86_64
clang "-ffile-prefix-map=$PWD=./lume-flow" -arch "$lume_arch" -isysroot "$lume_sdk" -mmacosx-version-min=14.0 -fobjc-arc -fmodules native/lume-helper.m -framework Cocoa -framework ApplicationServices -o build/lume-helper
