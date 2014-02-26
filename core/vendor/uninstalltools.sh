#卸载驱动程序编译工具
set -e

CHROOTDIR=~/cos/mkiso_out/squashfs-root
DEBDIR=~/app
DEBNAME=tools.tar.gz

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
#sudo cp ${DEBDIR}/${DEBNAME} ${CHROOTDIR}

sudo chroot ${CHROOTDIR} /bin/bash -c "echo 'chroot to squashfs-root'"
sudo chroot ${CHROOTDIR} /bin/bash -c "apt-get autoremove -y libcogl-dev autoconf xserver-xorg-dev xutils-dev libtool"

sudo chroot ${CHROOTDIR} /bin/bash -c "rm -rf /home/*"



echo "Driver tools has been uninstalled successful!"
