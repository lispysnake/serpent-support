#!/bin/bash
set -e

RUNTIME_DIR="`realpath .`/runtime"
EXTERNAL_DIR="`realpath ./external`"

BUILD_TYPE="linux-release64"

install -D -d -m 00755 "${RUNTIME_DIR}/bin"
install -D -d -m 00755 "${RUNTIME_DIR}/lib"

export CXX="ccache g++"
export CC="ccache gcc"

echo "Configuring bgfx"
pushd external/bgfx
BX_DIR="${EXTERNAL_DIR}/bx" BIMG_DIR="${EXTERNAL_DIR}/bimg" ${EXTERNAL_DIR}/bx/tools/bin/linux/genie --with-tools --with-shared-lib --with-wayland --gcc=linux-gcc gmake
make -R -C .build/projects/gmake-linux config=release64 -j`nproc`

# Install tooling
for tool in "shaderc" "texturec" "texturev"; do
    install -m 00755 ".build/linux64_gcc/bin/${tool}Release"  "${RUNTIME_DIR}/bin/${tool}"
done

# Install static variants
install -m 00755 ".build/linux64_gcc/bin/"*.a "${RUNTIME_DIR}/lib/."
