#!/bin/bash
source ./0_variables.sh
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

if [ -z ${WINE_HASH} ]; then
	# Using url of release:
	wget -q "https://dl.winehq.org/wine/source/5.x/wine-${WINE_VERSION}.tar.xz"
	tar xf "wine-${WINE_VERSION}.tar.xz" || die "* cant extract wine!"
	mv "wine-${WINE_VERSION}" "wine-src" || die "* cant rename wine-src!"
else
	# Using HASH:
	wget -q "https://github.com/wine-mirror/wine/archive/${WINE_HASH}.tar.gz"
	tar xf "${WINE_HASH}.tar.gz" || die "* cant extract wine!"
	mv "wine-${WINE_HASH}" "wine-src" || die "* cant rename wine-src!"
fi

#wget -q "https://github.com/wine-staging/wine-staging/archive/v${STAGING_VERSION}.tar.gz"
#tar xf "v${STAGING_VERSION}.tar.gz" || die "* cant extract wine-staging patchs!"
#echo "* Applying patchs..."
#"./wine-staging-${STAGING_VERSION}/patches/patchinstall.sh" DESTDIR="${WORKDIR}/wine-src" --all >"${WORKDIR}/staging_patches.txt" || die "* Cant apply the wine-staging patches!"
cd "${WORKDIR}/wine-src" || die "Cant enter on ${WORKDIR}/wine-src dir!"
#HAVE_TIMEOUT_PATCH="$(cat server/timer.c | grep TIMEOUT_INFINITE)"
#if [ -z "${HAVE_TIMEOUT_PATCH}" ]; then
#	echo "* Applying timeout_infinite_fix.patch..."
#	patch -p1 < "${WORKDIR}/patches/timeout_infinite_fix.patch" || die "Cant apply the timeout_infinite_fix.patch!"
#fi
#echo "* Applying revert_d28c793.patch..."
#patch -p1 < "${WORKDIR}/patches/revert_d28c793.patch" || die "Cant apply the revert_d28c793.patch!"
#echo "* Applying debug patches..."
#patch -p1 < "${WORKDIR}/patches/tmp_debug_1.patch" || die "Cant apply the tmp_debug_1.patch!"
#patch -p1 < "${WORKDIR}/patches/tmp_debug_2.patch" || die "Cant apply the tmp_debug_2.patch!"
#patch -p1 < "${WORKDIR}/patches/tmp_debug_3.patch" || die "Cant apply the tmp_debug_3.patch!"
#patch -p1 < "${WORKDIR}/patches/tmp_debug_4.patch" || die "Cant apply the tmp_debug_4.patch!"
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
