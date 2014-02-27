#安装kdump工具相关软件包,把此脚本放在build/debug/路径下,把app目录放在～/app下
set -e

CHROOTDIR=~/customize/mkiso_out/squashfs-root
DEBDIR=~/app
DEBNAME=kdump-1.5.1.tar.gz
#tar -cvzf /home/zzz/kdump/kdump-1.5.1.tar.gz kdump-1.5.1/

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

mkdir ${CHROOTDIR}/app
cp ${DEBDIR}/${DEBNAME} ${CHROOTDIR}/app

#********************start************************
sudo mount --bind /dev $CHROOTDIR/dev
sudo mount -t proc proc $CHROOTDIR/proc
#********************end**************************

chroot ${CHROOTDIR} /bin/bash -c "echo 'chroot to squashfs-root'"
chroot ${CHROOTDIR} /bin/bash -c "cd app && tar xvzf kdump-1.5.1.tar.gz"
chroot ${CHROOTDIR} /bin/bash -c "dpkg -i -E app/kdump-1.5.1/*.deb"


chroot ${CHROOTDIR} /bin/bash -c "rm -rf app"

#********************start************************
sudo umount $CHROOTDIR/proc
sudo umount $CHROOTDIR/dev
#********************end**************************

echo "Kdump installed successful!"


