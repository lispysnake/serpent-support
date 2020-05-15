#!/bin/bash
set -e

. common.sh

RUNTIME_DIR="`realpath .`/runtime"
EXTERNAL_DIR="`realpath ./external`"

install -D -d -m 00755 "${RUNTIME_DIR}/bin"
install -D -d -m 00755 "${RUNTIME_DIR}/lib"

echo "Cleaning Chipmunk2D"
rm -rf external/Chipmunk2D

echo "Initialising Chipmunk2D"
git submodule update --init --recursive external/Chipmunk2D

export CXX="ccache g++"
export CC="ccache gcc"

# TODO: Investigate using floats.
export CFLAGS="$CFLAGS -DCP_USE_DOUBLES=1"
export CXXFLAGS="$CXXFLAGS -DCP_USE_DOUBLES=1"

echo "Configuring Chipmunk2D"
pushd external/Chipmunk2D
cmake . -DCMAKE_BUILD_TYPE=RelWithDebInfo -DOpenGL_GL_PREFERENCE=LEGACY -DBUILD_DEMOS=OFF -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_C_FLAGS="$CFLAGS" -DCMAKE_CXX_FLAGS="$CXXFLAGS"
make -j`nproc`

echo "Installing Chipmunk2D"
install -m 00755 src/*.a "${RUNTIME_DIR}/lib/." -v
