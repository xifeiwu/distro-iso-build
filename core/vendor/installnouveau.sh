#安装最新nouveau驱动程序
set -e

CHROOTDIR=~/cos/mkiso_out/squashfs-root
DEBDIR=~/app
DEBNAME=nouveau.tar.gz

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
sudo chroot ${CHROOTDIR} /bin/bash -c "apt-get install -y autoconf libtool libpthread-stubs0-dev libpciaccess-dev xutils-dev xserver-xorg-dev"
sudo chroot ${CHROOTDIR} /bin/bash -c "tar xvf nouveau.tar.gz && cd /nouveau && tar xvf drm-2.4.51.tar.gz && tar xvf xf86-video-nouveau-1.0.10.tar.gz"
sudo chroot ${CHROOTDIR} /bin/bash -c "source /nouveau/nouveau-env.sh && cd /nouveau/drm-2.4.51/ && ./autogen.sh --prefix=/usr && make && make install"
sudo chroot ${CHROOTDIR} /bin/bash -c "source /nouveau/nouveau-env.sh && cd /nouveau/xf86-video-nouveau-1.0.10/ && ./autogen.sh --prefix=/usr && make && make install"


sudo chroot ${CHROOTDIR} /bin/bash -c "rm -rf /nouveau /var/cache/apt/archives/*.deb /nouveau.tar.gz"
sudo chroot ${CHROOTDIR} /bin/bash -c "rm -rf /home/*"



echo "Nouveau installed successful!"
