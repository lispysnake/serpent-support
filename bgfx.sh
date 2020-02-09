#!/bin/bash
set -e

# We could use submodules and whatnot, but honestly my internet is so god-awful
# im relying on this weird build helper.

BGFX_COMMIT="17db2f79e0aa57e0af78142223c993882a64382d"
BX_COMMIT="6b1afd9f9ba1ebf3da1302339ee31f992fd78687"
BIMG_COMMIT="29a722a7298744424b8dfe83e06abf04a75e9fea"

DOWNLOAD_DIR="`realpath .`/downloads"
STAGING_DIR="`realpath .`/staging"
RUNTIME_DIR="`realpath .`/runtime"

BUILD_TYPE="linux-release64"

# Helper to download a URL to a filename
function download_one()
{
    local filename="$1"
    local url="$2"

    if [[ -e "${DOWNLOAD_DIR}/${filename}" ]]; then
        echo "Skipping download of ${filename}"
        return
    fi
    echo "Downloading ${filename}"
    wget "${url}" -O "${DOWNLOAD_DIR}/${filename}"
}

function extract_one()
{
    local filename="$1"
    local gcommit="$2"
    local dirp="${filename%.zip}"
    if [[ -e "${STAGING_DIR}/${dirp}" ]]; then
        echo "Skipping extraction of ${filename}"
        return
    fi
    echo "Extracting ${filename}"
    unzip "${DOWNLOAD_DIR}/${filename}" -d "${STAGING_DIR}"
    mv "${STAGING_DIR}/${dirp}-${gcommit}" "${STAGING_DIR}/${dirp}"
}

install -D -d -m 00755 "${DOWNLOAD_DIR}"
install -D -d -m 00755 "${STAGING_DIR}"
install -D -d -m 00755 "${RUNTIME_DIR}/bin"
install -D -d -m 00755 "${RUNTIME_DIR}/lib"

download_one "bgfx.zip" "https://github.com/bkaradzic/bgfx/archive/${BGFX_COMMIT}.zip"
download_one "bimg.zip" "https://github.com/bkaradzic/bimg/archive/${BIMG_COMMIT}.zip"
download_one "bx.zip" "https://github.com/bkaradzic/bx/archive/${BX_COMMIT}.zip"


extract_one "bgfx.zip" "${BGFX_COMMIT}"
extract_one "bimg.zip" "${BIMG_COMMIT}"
extract_one "bx.zip" "${BX_COMMIT}"

export CXX="ccache g++"
export CC="ccache gcc"

echo "Building bx"
pushd staging/bx/
make "${BUILD_TYPE}" -j`nproc`
popd

echo "Building bimg"
pushd staging/bimg/
make "${BUILD_TYPE}" -j`nproc`
popd

echo "Building bgfx"
pushd staging/bgfx/
make "${BUILD_TYPE}" -j`nproc`
popd

# Install tooling
for tool in "shaderc" "texturec" "texturev"; do
    install -m 00755 "staging/bgfx/.build/linux64_gcc/bin/${tool}Release"  "${RUNTIME_DIR}/bin/${tool}"
done

# Install runtime libs
install -m 00755 "staging/bgfx/.build/linux64_gcc/bin/"*.so "${RUNTIME_DIR}/lib/."
install -m 00644 "staging/bgfx/.build/linux64_gcc/bin/"*.a "${RUNTIME_DIR}/lib/."
