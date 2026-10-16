#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
lume_arch="${LUME_ARCH:-arm64}"
[ "$lume_arch" != x64 ] || lume_arch=x86_64
lume_sdk="${LUME_SDKROOT:-$(xcrun --show-sdk-path)}"
lume_cmake="${LUME_CMAKE:-cmake}"
mkdir -p .local build
if [ ! -d .local/whisper.cpp/.git ]; then git clone --depth 1 --branch v1.8.7 https://github.com/ggml-org/whisper.cpp.git .local/whisper.cpp; fi
[ "$(git -C .local/whisper.cpp rev-parse HEAD)" = 48f628a84833905ee4a0658ee6d4a5c915ce1997 ] || { echo 'Versão do motor divergente'; exit 1; }
SDKROOT="$lume_sdk" "$lume_cmake" -S .local/whisper.cpp -B ".local/engine-$lume_arch" -DCMAKE_OSX_SYSROOT="$lume_sdk" -DCMAKE_BUILD_TYPE=Release "-DCMAKE_C_FLAGS=-ffile-prefix-map=$PWD=./lume-flow" "-DCMAKE_CXX_FLAGS=-ffile-prefix-map=$PWD=./lume-flow" -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 -DCMAKE_OSX_ARCHITECTURES="$lume_arch" -DBUILD_SHARED_LIBS=OFF -DGGML_NATIVE=OFF -DGGML_METAL_EMBED_LIBRARY=ON -DGGML_OPENMP=OFF -DWHISPER_BUILD_TESTS=OFF -DWHISPER_BUILD_EXAMPLES=ON -DWHISPER_BUILD_SERVER=ON
"$lume_cmake" --build ".local/engine-$lume_arch" --target whisper-server -j 4
cp ".local/engine-$lume_arch/bin/whisper-server" build/whisper-server
otool -L build/whisper-server

cp build/whisper-server "build/Lume Server"
