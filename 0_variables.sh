#!/bin/bash
#export WINE_VERSION="5.17"
# using source from: https://github.com/wine-mirror/wine
# ref with the patch, bad 5.18 d28c7938c704fe4dcfc8920db494a7175a46fe6b
# ref with the patch, good d28c7938c704fe4dcfc8920db494a7175a46fe6b
# with patch test Manual i7 - side 2 to the first regression log get
export WINE_HASH="4e11e6e045edd514d553d32ef797cecf98d9a203"
export WINE_VERSION="$(echo "${WINE_HASH}" | cut -c1-7)"
export STAGING_VERSION="${WINE_VERSION}"

export SDL2_VERSION="2.0.12"
export FAUDIO_VERSION="20.08"
export VULKAN_VERSION="1.2.145"
export SPIRV_VERSION="1.5.3"


export CHROOT_DISTRO="bionic"
export CHROOT_MIRROR="http://archive.ubuntu.com/ubuntu/"

# amd64 or i386
export UBUNTU_ARCH=amd64

# nehalem go up to sse4.2
export CFLAGS="-march=nehalem -O2 -pipe -ftree-vectorize -fno-stack-protector"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-Wl,-O1,--sort-common,--as-needed"

# ccache:
WORKDIR=$(pwd)
export CCACHE_DIR="${WORKDIR}/ccache"
export CC="ccache gcc"
#export CROSSCC="ccache i686-w64-mingw32-gcc"
