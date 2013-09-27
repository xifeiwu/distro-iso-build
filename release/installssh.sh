#安装ssh

set -e

CHROOTDIR=~/cos/mkiso_out/squashfs-root
DEBDIR=~/app
DEBNAME=ssh.tar.gz

if [ ! -e "${CHROOTDIR}" ]; then
    echo "squashfs-root not found"
    exit
fi

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


mkdir ${CHROOTDIR}/app
sudo cp ${DEBDIR}/${DEBNAME} ${CHROOTDIR}/app

sudo chroot ${CHROOTDIR} /bin/bash -c "echo 'chroot to squashfs-root'"
sudo chroot ${CHROOTDIR} /bin/bash -c "cd app && tar xvf ssh.tar.gz"
sudo chroot ${CHROOTDIR} /bin/bash -c "dpkg -i app/ssh/*.deb"


sudo chroot ${CHROOTDIR} /bin/bash -c "rm -rf app"

echo "Ssh installed successful!"


