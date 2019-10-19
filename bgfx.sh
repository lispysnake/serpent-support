#!/bin/bash
set -e

# We could use submodules and whatnot, but honestly my internet is so god-awful
# im relying on this weird build helper.

BGFX_COMMIT="b71cea176b190601a6a7dd51eacc3ed05e512e80"
BX_COMMIT="a9e8a24b60d25d79ec1e5fe177b769da17f9eb67"
BIMG_COMMIT="bd81f6030a46f9445ddc5ae42bd0a2a91cc7d83f"

DOWNLOAD_DIR="downloads"

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

if [[ ! -d "${DOWNLOAD_DIR}" ]]; then
    mkdir "${DOWNLOAD_DIR}"
fi

download_one "bgfx.zip" "https://github.com/bkaradzic/bgfx/archive/${BGFX_COMMIT}.zip"
download_one "bimg.zip" "https://github.com/bkaradzic/bimg/archive/${BIMG_COMMIT}.zip"
download_one "bx.zip" "https://github.com/bkaradzic/bx/archive/${BX_COMMIT}.zip"
