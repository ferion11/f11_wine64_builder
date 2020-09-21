#!/bin/bash
export WINE_VERSION="5.17"
export STAGING_VERSION="${WINE_VERSION}.2"

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

echo "* Wine part:"
echo "* Getting wine source and patch..."
wget -q "https://dl.winehq.org/wine/source/5.x/wine-${WINE_VERSION}.tar.xz"
tar xf "wine-${WINE_VERSION}.tar.xz" || die "* cant extract wine!"
mv "wine-${WINE_VERSION}" "wine-src" || die "* cant rename wine-src!"


wget -q "https://github.com/wine-staging/wine-staging/archive/v${STAGING_VERSION}.tar.gz"
tar xf "v${STAGING_VERSION}.tar.gz" || die "* cant extract wine-staging patchs!"
echo "* Applying patchs..."
"./wine-staging-${STAGING_VERSION}/patches/patchinstall.sh" DESTDIR="${WORKDIR}/wine-src" --all >"${WORKDIR}/staging_patches.txt" || die "* Cant apply the wine-staging patches!"
cd "${WORKDIR}/wine-src" || die "Cant enter on ${WORKDIR}/wine-src dir!"
patch -p1 < "${WORKDIR}/patches/timeout_infinite_fix.patch" || die "Cant apply the timeout_infinite_fix.patch!"
patch -p1 < "${WORKDIR}/patches/timeout_overflow_fix.patch" || die "Cant apply the timeout_overflow_fix.patch!"
cd "${WORKDIR}" || die "Cant enter on ${WORKDIR} dir!"


echo "* Compiling..."
mkdir "build64"
mkdir "build32"
mkdir "wine-inst"

# compile 64bits first
cd "${WORKDIR}/build64" || die "* Cant enter on the ${WORKDIR}/build64 dir!"
../wine-src/configure --enable-win64 --prefix "${WORKDIR}/wine-inst" --disable-tests
make -j"$(nproc)" --no-print-directory || die "* cant make wine64!"

cd "${WORKDIR}" || die "Cant enter on ${WORKDIR} dir!"
