#安装openoffice,把此脚本放在squashfs-root/../路径下,把app目录放在～/app下
set -e

CHROOTDIR=~/customize/squashfs-root
DEBDIR=~/app
DEBNAME=Apache_OpenOffice_4.0.0_Linux_x86_install-deb_zh-CN.tar.gz

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

if [ ! -e "${DEBDIR}" ]; then
    echo "source deb not found"
    exit
fi

mkdir ${CHROOTDIR}/app
sudo cp ${DEBDIR}/${DEBNAME} ${CHROOTDIR}/app

sudo chroot ${CHROOTDIR} /bin/bash -c "echo 'chroot to squashfs-root'"
sudo chroot ${CHROOTDIR} /bin/bash -c "cd app && tar xvf Apache_OpenOffice_4.0.0_Linux_x86_install-deb_zh-CN.tar.gz"
sudo chroot ${CHROOTDIR} /bin/bash -c "dpkg -i -E app/zh-CN/DEBS/*.deb"
sudo chroot ${CHROOTDIR} /bin/bash -c "rm -rf app"

echo "openoffice installed successful!"


