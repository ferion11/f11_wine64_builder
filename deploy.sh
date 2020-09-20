#!/bin/bash
export WINE_VERSION="5.17"
export STAGING_VERSION="${WINE_VERSION}"
export SDL2_VERSION="2.0.12"
export FAUDIO_VERSION="20.08"
export VULKAN_VERSION="1.2.145"
export SPIRV_VERSION="1.5.3"

export CHROOT_DISTRO="bionic"
export CHROOT_MIRROR="http://archive.ubuntu.com/ubuntu/"

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

# Ubuntu Main Repos:
sudo echo "deb ${CHROOT_MIRROR} ${CHROOT_DISTRO} main restricted universe multiverse" > /etc/apt/sources.list
sudo echo "deb-src ${CHROOT_MIRROR} ${CHROOT_DISTRO} main restricted universe multiverse" >> /etc/apt/sources.list

###### Ubuntu Update Repos:
sudo echo "deb ${CHROOT_MIRROR} ${CHROOT_DISTRO}-security main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb ${CHROOT_MIRROR} ${CHROOT_DISTRO}-updates main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb ${CHROOT_MIRROR} ${CHROOT_DISTRO}-proposed main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb ${CHROOT_MIRROR} ${CHROOT_DISTRO}-backports main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb-src ${CHROOT_MIRROR} ${CHROOT_DISTRO}-security main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb-src ${CHROOT_MIRROR} ${CHROOT_DISTRO}-updates main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb-src ${CHROOT_MIRROR} ${CHROOT_DISTRO}-proposed main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb-src ${CHROOT_MIRROR} ${CHROOT_DISTRO}-backports main restricted universe multiverse" >> /etc/apt/sources.list

sudo dpkg --add-architecture i386
#sudo apt-get -q -y update
#echo "* Install software-properties-common..."
#sudo apt-get -q -y install software-properties-common apt-utils || die "* apt software-properties-common and apt-utils erro!"

# gcc-9 ppa:
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test >/dev/null

echo "* update, upgrade and dist-upgrade..."
sudo apt-get -q -y update >/dev/null
sudo apt-get -q -y upgrade >/dev/null
#sudo apt-get -q -y dist-upgrade

echo "* Install deps..."
sudo apt-get -q -y install wget git sudo make cmake gcc-multilib g++-multilib tar gzip xz-utils bzip2 gawk sed flex bison >/dev/null || die "* apt basic erro!"
sudo apt-get -q -y install libfreetype6-dev libfreetype6-dev:i386 libfontconfig1-dev libfontconfig1-dev:i386 libglu1-mesa-dev libglu1-mesa-dev:i386 libosmesa6-dev libosmesa6-dev:i386 libvulkan-dev libvulkan-dev:i386 libvulkan1 libvulkan1:i386 libpulse-dev libpulse-dev:i386 libopenal-dev libopenal-dev:i386 libncurses-dev libncurses-dev:i386 libgnutls28-dev libtiff-dev libldap-dev libldap-dev:i386 libcapi20-dev libcapi20-dev:i386 libpcap-dev libpcap-dev:i386 libxml2-dev libmpg123-dev libmpg123-dev:i386 libgphoto2-dev libgphoto2-dev:i386 libsane-dev libsane-dev:i386 libcupsimage2-dev libkrb5-dev libkrb5-dev:i386 libgsm1-dev libgsm1-dev:i386 libxslt1-dev libv4l-dev libv4l-dev:i386 libgstreamer-plugins-base1.0-dev:i386 libudev-dev libudev-dev:i386 libxi-dev libxi-dev:i386 liblcms2-dev liblcms2-dev:i386 libibus-1.0-dev libibus-1.0-dev:i386 libsdl2-dev ocl-icd-opencl-dev ocl-icd-opencl-dev:i386 libxinerama-dev libxinerama-dev:i386 libxcursor-dev libxcursor-dev:i386 libxrandr-dev libxrandr-dev:i386 libxcomposite-dev libxcomposite-dev:i386 libavcodec57 libavcodec57:i386 libavcodec-dev libavcodec-dev:i386 libswresample2 libswresample2:i386 libswresample-dev libswresample-dev:i386 libavutil55 libavutil55:i386 libavutil-dev libavutil-dev:i386 libusb-1.0-0-dev libusb-1.0-0-dev:i386 libgcrypt20-dev libasound2-dev libasound2-dev:i386 libjpeg8-dev libjpeg8-dev:i386 libldap2-dev libldap2-dev:i386 libx11-dev libx11-dev:i386 zlib1g-dev zlib1g-dev:i386 libcups2 libcups2:i386 libdbus-1-3 libdbus-1-3:i386 libicu-dev libncurses5 libncurses5:i386 >/dev/null || die "* main apt erro!"
# removed: xserver-xorg-dev xserver-xorg-dev:i386 libgcrypt20-dev:i386 libgnutls28-dev:i386 libicu-dev:i386 libtiff-dev:i386 libxml2-dev:i386 libgstreamer-plugins-base1.0-dev libcupsimage2-dev:i386 libxslt1-dev:i386 libsdl2-dev:i386
sudo apt-get -q -y purge libvulkan-dev libvulkan1 libsdl2-dev libsdl2-2.0-0 --purge --autoremove >/dev/null || die "* apt purge error!"
# removed  libfaudio0:i386 libfaudio-dev:i386 (building it below), libvkd3d-dev:i386

echo "* compile and install more deps..."
mkdir "${WORKDIR}/build_libs"
cd "${WORKDIR}/build_libs" || die "* Cant enter on dir build_libs!"

echo "* downloading SDL2..."
wget -q "https://www.libsdl.org/release/SDL2-${SDL2_VERSION}.tar.gz"
echo "* downloading FAudio..."
wget -q "https://github.com/FNA-XNA/FAudio/archive/${FAUDIO_VERSION}.tar.gz" -O "FAudio-${FAUDIO_VERSION}.tar.gz"
echo "* downloading Vulkan-Headers..."
wget -q "https://github.com/KhronosGroup/Vulkan-Headers/archive/v${VULKAN_VERSION}.tar.gz" -O "Vulkan-Headers-${VULKAN_VERSION}.tar.gz"
echo "* downloading Vulkan-Loader..."
wget -q "https://github.com/KhronosGroup/Vulkan-Loader/archive/v${VULKAN_VERSION}.tar.gz" -O "Vulkan-Loader-${VULKAN_VERSION}.tar.gz"
echo "* downloading SPIRV-Headers..."
wget -q "https://github.com/KhronosGroup/SPIRV-Headers/archive/${SPIRV_VERSION}.tar.gz"  -O "SPIRV-Headers-${SPIRV_VERSION}.tar.gz"
git clone --depth 1 https://github.com/HansKristian-Work/vkd3d-proton.git

echo "* extracting..."
tar xf "SDL2-${SDL2_VERSION}.tar.gz" || die "* extract tar.gz error!"
tar xf "FAudio-${FAUDIO_VERSION}.tar.gz" || die "* extract tar.gz error!"
tar xf "Vulkan-Headers-${VULKAN_VERSION}.tar.gz" || die "* extract tar.gz error!"
tar xf "Vulkan-Loader-${VULKAN_VERSION}.tar.gz" || die "* extract tar.gz error!"
tar xf "SPIRV-Headers-${SPIRV_VERSION}.tar.gz" || die "* extract tar.gz error!"

build_and_install() {
	echo "* Building and installing: $1"
	mkdir build
	cd build || die "* Cant enter on build dir!"
	cmake ../"$1" >/dev/null
	make -j"$(nproc)" >/dev/null || die "* Cant make $1!"
	sudo make install >/dev/null || die "* Cant install $1!"
	cd ../ && sudo rm -r build
}

build_and_install "SDL2-${SDL2_VERSION}"
build_and_install "FAudio-${FAUDIO_VERSION}"
build_and_install "Vulkan-Headers-${VULKAN_VERSION}"
build_and_install "Vulkan-Loader-${VULKAN_VERSION}"
build_and_install "SPIRV-Headers-${SPIRV_VERSION}"
# Need libvkd3d-dev package that refuse to install on ${CHROOT_DISTRO}, so workaround:
echo "* compiling and install vkd3d-proton>"
wget -q https://dl.winehq.org/wine-builds/ubuntu/dists/${CHROOT_DISTRO}/main/binary-amd64/wine-stable_5.0.2~${CHROOT_DISTRO}_amd64.deb
dpkg -x wine-stable_5.0.2~${CHROOT_DISTRO}_amd64.deb ./
sudo cp ./opt/wine-stable/bin/widl /usr/bin/ || die "cant copy widl erro!"
cd vkd3d-proton || die "* Cant enter on vkd3d-proton dir!"
./autogen.sh >/dev/null
./configure >/dev/null || die "* vkd3d-proton configure error!"
make -j"$(nproc)" >/dev/null || die "* vkd3d-proton make error!"
sudo make install >/dev/null || die "* vkd3d-proton install error!"

cd "${WORKDIR}" || die "Cant enter on ${WORKDIR} dir!"
sudo rm -rf "${WORKDIR}/build_libs"
#==============================================================================

echo "* Wine part:"
echo "* Getting wine source and patch..."
wget -q "https://dl.winehq.org/wine/source/5.x/wine-${WINE_VERSION}.tar.xz"
tar xf "wine-${WINE_VERSION}.tar.xz" || die "* cant extract wine!"
mv "wine-${WINE_VERSION}" "wine-src" || die "* cant rename wine-src!"

#echo "* Applying patchs..."

echo "* Compiling..."

mkdir "build64"
mkdir "build32"
mkdir "wine-inst"

# compile 64bits first
cd "${WORKDIR}/build64" || die "* Cant enter on the ${WORKDIR}/build64 dir!"
../wine-src/configure --enable-win64 --prefix "${WORKDIR}/wine-inst" --disable-tests
make -j"$(nproc)" --no-print-directory || die "* cant make wine64!"

# compile 32bbits
cd "${WORKDIR}/build32" || die "* Cant enter on the ${WORKDIR}/build32 dir!"
PKG_CONFIG_PATH="/usr/lib/i386-linux-gnu/pkgconfig:/usr/lib32/pkgconfig" ../wine-src/configure --with-wine64=../build64 --prefix "${WORKDIR}/wine-inst" --disable-tests
make -j"$(nproc)" --no-print-directory || die "* cant make wine32!"

# install (the 32bits first)
make install --no-print-directory || die "* cant install wine!"
cd "${WORKDIR}/build64" || die "* Cant enter on the ${WORKDIR}/build64 dir!"
make install --no-print-directory || die "* cant install wine!"

#-------------------------------------------------
cd "${WORKDIR}/wine-inst" || die "* Cant enter on the wine-inst dir!"

echo "* Cleaning..."
sudo rm -r include && sudo rm -r share/applications && sudo rm -r share/man

# Will do it on he appimage making only, because one can use this native feature
#echo "* disabling winemenubuilder.exe..."
#sed 's/winemenubuilder.exe -a -r/winemenubuilder.exe -r/g' ./share/wine/wine.inf -i
#
#echo "* disabling FileOpenAssociations..."
#sed 's|    LicenseInformation|    LicenseInformation,\\\n    FileOpenAssociations|g;$a \\n[FileOpenAssociations]\nHKCU,Software\\Wine\\FileOpenAssociations,"Enable",,"N"' ./share/wine/wine.inf -i

echo "* Compressing: wine-vanilla-${WINE_VERSION}.tar.gz"
tar czf "${WORKDIR}/wine-vanilla-${WINE_VERSION}.tar.gz" *

cd "${WORKDIR}" || die "Cant enter on ${WORKDIR} dir!"
mv *.tar.gz result/
#-------------------------------------------------
