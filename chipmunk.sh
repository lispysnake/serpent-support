#!/bin/bash
set -e

RUNTIME_DIR="`realpath .`/runtime"
EXTERNAL_DIR="`realpath ./external`"

install -D -d -m 00755 "${RUNTIME_DIR}/bin"
install -D -d -m 00755 "${RUNTIME_DIR}/lib"

export CXX="ccache g++"
export CC="ccache gcc"

echo "Configuring Chipmunk2D"
pushd external/Chipmunk2D
cmake . -DCMAKE_BUILD_TYPE=RelWithDebInfo -G "Unix Makefiles" -Dprefix=/usr
make -j`nproc`

echo "Installing Chipmunk2D"
cp -v --no-dereference src/*.so* "${RUNTIME_DIR}/lib/."
