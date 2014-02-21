#安装upstream ati驱动程序
set -e

CHROOTDIR=~/cos/mkiso_out/squashfs-root
DEBDIR=~/app
DEBNAME=ati.tar.gz

if [ -z "$1" ] ; then
    echo error: No chrootdir setting at first param.
    exit -1
fi

if [ -z "$2" ] ; then
    echo error: No deb dir setting at second param.
    exit -1
fi

CHROOTDIR=$1/squashfs-root
DEBDIR=$2

if [ ! -e "${CHROOTDIR}" ]; then
    echo "squashfs-root not found"
    exit
fi

#mkdir ${CHROOTDIR}/app
sudo cp ${DEBDIR}/${DEBNAME} ${CHROOTDIR}

sudo chroot ${CHROOTDIR} /bin/bash -c "echo 'chroot to squashfs-root'"
sudo chroot ${CHROOTDIR} /bin/bash -c "apt-get remove -y xserver-xorg-video-ati xserver-xorg-video-radeon"
#sudo chroot ${CHROOTDIR} /bin/bash -c "apt-get install -y libcogl-dev autoconf xserver-xorg-dev xutils-dev libtool"
sudo chroot ${CHROOTDIR} /bin/bash -c "tar xvf ati.tar.gz && cd /ati && tar xvf xf86-video-ati-7.3.0.tar.gz && cd tools && tar xvf glamor-egl-0.6.0.tar.gz && tar xvf libdrm-2.4.52.tar.gz"
sudo chroot ${CHROOTDIR} /bin/bash -c "cd ati/tools/libdrm-2.4.52 && ./configure && make &&make install"
sudo chroot ${CHROOTDIR} /bin/bash -c "cd ati/tools/glamor-egl-0.6.0 && ./autogen.sh --prefix=/usr && make && make install"
sudo chroot ${CHROOTDIR} /bin/bash -c "cd ati/xf86-video-ati-7.3.0 && ./autogen.sh --prefix=/usr && make && make install"

sudo chroot ${CHROOTDIR} /bin/bash -c "rm -rf /ati ati.tar.gz"
sudo chroot ${CHROOTDIR} /bin/bash -c "rm -rf /home/*"



echo "xf86-video-ati installed successful!"
