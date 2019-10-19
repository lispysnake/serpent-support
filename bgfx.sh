#!/bin/bash
set -e

# We could use submodules and whatnot, but honestly my internet is so god-awful
# im relying on this weird build helper.

BGFX_COMMIT="b71cea176b190601a6a7dd51eacc3ed05e512e80"
BX_COMMIT="a9e8a24b60d25d79ec1e5fe177b769da17f9eb67"
BIMG_COMMIT="bd81f6030a46f9445ddc5ae42bd0a2a91cc7d83f"

DOWNLOAD_DIR="downloads"
STAGING_DIR="staging"

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

if [[ ! -d "${DOWNLOAD_DIR}" ]]; then
    mkdir "${DOWNLOAD_DIR}"
fi

if [[ ! -d "${STAGING_DIR}" ]]; then
    mkdir "${STAGING_DIR}"
fi

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

mkdir -p bin
mkdir -p lib

# Install tooling
for tool in "shaderc" "texturec" "texturev"; do
    install -m 00755 "staging/bgfx/.build/linux64_gcc/bin/${tool}Release"  "./bin/${tool}"
done

# Install runtime libs
install -m 00755 "staging/bgfx/.build/linux64_gcc/bin/"*.so "./lib/."
install -m 00644 "staging/bgfx/.build/linux64_gcc/bin/"*.a "./lib/."
