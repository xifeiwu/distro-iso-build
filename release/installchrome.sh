#安装google-chrome,把此脚本放在squashfs-root/../路径下,把app目录放在～/app下
set -e

CHROOTDIR=~/pcos/mkiso_out/squashfs-root
DEBDIR=~/pcos/app
DEBNAME=google-chrome-stable_current_i386.deb

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

chroot ${CHROOTDIR} /bin/bash -c "apt-get remove -y firefox"
chroot ${CHROOTDIR} /bin/bash -c "cd app && dpkg -i google-chrome-stable_current_i386.deb"
chroot ${CHROOTDIR} /bin/bash -c "rm -rf app"

echo "google-chrome installed successful!"
