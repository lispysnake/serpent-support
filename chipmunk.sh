#!/bin/bash
set -e

. common.sh

RUNTIME_DIR="`realpath .`/runtime"
EXTERNAL_DIR="`realpath ./external`"

install -D -d -m 00755 "${RUNTIME_DIR}/bin"
install -D -d -m 00755 "${RUNTIME_DIR}/lib"

export CXX="ccache g++"
export CC="ccache gcc"

echo "Configuring Chipmunk2D"
pushd external/Chipmunk2D
cmake . -DCMAKE_BUILD_TYPE=RelWithDebInfo -DOpenGL_GL_PREFERENCE=LEGACY -DBUILD_DEMOS=OFF -G "Unix Makefiles" -Dprefix=/usr
make -j`nproc`

echo "Installing Chipmunk2D"
install -m 00755 src/*.a "${RUNTIME_DIR}/lib/." -v
