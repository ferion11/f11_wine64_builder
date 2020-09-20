#!/bin/bash
export CHROOT_DISTRO="bionic"
export CHROOT_MIRROR="http://archive.ubuntu.com/ubuntu/"
#==============================================================================

#=================================================
die() { echo >&2 "$*"; exit 1; };
#=================================================
#==============================================================================
cat /etc/issue
WORKDIR=$(pwd)
echo "* Working inside ${WORKDIR}"

# Ubuntu Main Repos:
echo "deb ${CHROOT_MIRROR} ${CHROOT_DISTRO} main restricted universe multiverse" | sudo tee /etc/apt/sources.list
echo "deb-src ${CHROOT_MIRROR} ${CHROOT_DISTRO} main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list

###### Ubuntu Update Repos:
echo "deb ${CHROOT_MIRROR} ${CHROOT_DISTRO}-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
echo "deb ${CHROOT_MIRROR} ${CHROOT_DISTRO}-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
echo "deb ${CHROOT_MIRROR} ${CHROOT_DISTRO}-proposed main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
echo "deb ${CHROOT_MIRROR} ${CHROOT_DISTRO}-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
echo "deb-src ${CHROOT_MIRROR} ${CHROOT_DISTRO}-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
echo "deb-src ${CHROOT_MIRROR} ${CHROOT_DISTRO}-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
echo "deb-src ${CHROOT_MIRROR} ${CHROOT_DISTRO}-proposed main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
echo "deb-src ${CHROOT_MIRROR} ${CHROOT_DISTRO}-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list

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
sudo apt-get -q -y install libfreetype6-dev libfreetype6-dev:i386 libfontconfig1-dev libfontconfig1-dev:i386 libglu1-mesa-dev libglu1-mesa-dev:i386 libosmesa6-dev libosmesa6-dev:i386 libvulkan-dev libvulkan-dev:i386 libvulkan1 libvulkan1:i386 libpulse-dev libpulse-dev:i386 libopenal-dev libopenal-dev:i386 libncurses-dev libncurses-dev:i386 libgnutls28-dev libtiff-dev libldap-dev libldap-dev:i386 libcapi20-dev libcapi20-dev:i386 libpcap-dev libpcap-dev:i386 libxml2-dev libmpg123-dev libmpg123-dev:i386 libgphoto2-dev libgphoto2-dev:i386 libsane-dev libsane-dev:i386 libcupsimage2-dev libkrb5-dev libkrb5-dev:i386 libgsm1-dev libgsm1-dev:i386 libxslt1-dev libv4l-dev libv4l-dev:i386 libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libudev-dev libudev-dev:i386 libxi-dev libxi-dev:i386 liblcms2-dev liblcms2-dev:i386 libibus-1.0-dev libibus-1.0-dev:i386 libsdl2-dev ocl-icd-opencl-dev ocl-icd-opencl-dev:i386 libxinerama-dev libxinerama-dev:i386 libxcursor-dev libxcursor-dev:i386 libxrandr-dev libxrandr-dev:i386 libxcomposite-dev libxcomposite-dev:i386 libavcodec57 libavcodec57:i386 libavcodec-dev libavcodec-dev:i386 libswresample2 libswresample2:i386 libswresample-dev libswresample-dev:i386 libavutil55 libavutil55:i386 libavutil-dev libavutil-dev:i386 libusb-1.0-0-dev libusb-1.0-0-dev:i386 libgcrypt20-dev libasound2-dev libasound2-dev:i386 libjpeg8-dev libjpeg8-dev:i386 libldap2-dev libldap2-dev:i386 libx11-dev libx11-dev:i386 zlib1g-dev zlib1g-dev:i386 libcups2 libcups2:i386 libdbus-1-3 libdbus-1-3:i386 libicu-dev libncurses5 libncurses5:i386 >/dev/null || die "* main apt erro!"
# removed: xserver-xorg-dev xserver-xorg-dev:i386 libgcrypt20-dev:i386 libgnutls28-dev:i386 libicu-dev:i386 libtiff-dev:i386 libxml2-dev:i386 libcupsimage2-dev:i386 libxslt1-dev:i386 libsdl2-dev:i386 libgstreamer-plugins-base1.0-dev:i386
sudo apt-get -q -y purge libvulkan-dev libvulkan1 libsdl2-dev libsdl2-2.0-0 --purge --autoremove >/dev/null || die "* apt purge error!"
# removed  libfaudio0:i386 libfaudio-dev:i386 (building it below), libvkd3d-dev:i386

cd "${WORKDIR}" || die "Cant enter on ${WORKDIR} dir!"
