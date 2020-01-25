#!/bin/bash
set -e

# We could use submodules and whatnot, but honestly my internet is so god-awful
# im relying on this weird build helper.

BGFX_COMMIT="b9ab564c47386b5683a56a1d60ac4c4e3a0761bd"
BX_COMMIT="ead3450ec77c46a2f32365ffaf3742fbc653e414"
BIMG_COMMIT="23d2cd1738b6fca5e9429cc798059e7ad4ef181c"

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
