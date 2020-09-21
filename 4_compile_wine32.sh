#!/bin/bash

# nehalem go up to sse4.2
export CFLAGS="-march=nehalem -O2 -pipe -ftree-vectorize -fno-stack-protector"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-Wl,-O1,--sort-common,--as-needed"
#==============================================================================

#=================================================
die() { echo >&2 "$*"; exit 1; };
#=================================================
#==============================================================================
cat /etc/issue
WORKDIR=$(pwd)
echo "* Working inside ${WORKDIR}"

#change packages to 32bits ones, here:
sudo apt-get -q -y build-dep libgcrypt20-dev:i386 libtiff-dev:i386 libcupsimage2-dev:i386 libgstreamer-plugins-base1.0-dev:i386 libgnutls28-dev:i386 libxml2:i386 >/dev/null || die "* Error apt-get 32bits!"

# compile 32bbits
cd "${WORKDIR}/build32" || die "* Cant enter on the ${WORKDIR}/build32 dir!"
PKG_CONFIG_PATH="/usr/lib/i386-linux-gnu/pkgconfig:/usr/lib32/pkgconfig" ../wine-src/configure --with-wine64=../build64 --prefix "${WORKDIR}/wine-inst" --disable-tests
#make -j"$(nproc)" --no-print-directory || die "* cant make wine32!"

cd "${WORKDIR}" || die "Cant enter on ${WORKDIR} dir!"
