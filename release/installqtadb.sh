#安装qtadb
set -e

CHROOTDIR=~/pcos/mkiso_out/squashfs-root
DEBDIR=~/pcos/app
DEBNAME=qtadbdeb_2.0_i386.deb

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
    exit -1
fi

mkdir ${CHROOTDIR}/app
cp ${DEBDIR}/${DEBNAME} ${CHROOTDIR}/app

chroot ${CHROOTDIR} /bin/bash -c "cd app && dpkg -i qtadbdeb_2.0_i386.deb"
chroot ${CHROOTDIR} /bin/bash -c "rm -rf app"

echo "Qtadb installed successful!"
