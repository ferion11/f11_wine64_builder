#!/bin/bash
#export WINE_VERSION="5.17"
# using source from: https://github.com/wine-mirror/wine
# step 5
export WINE_HASH="d26ad6db7d5a70c49d051af403d9befe2be7c8f8"
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
