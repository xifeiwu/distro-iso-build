#~bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No chrootdir setting at first param.
    exit -1
fi

CHROOTDIR=$1/squashfs-root

if [ ! -e "${CHROOTDIR}" ]; then
    echo "squashfs-root not found"
    exit -1
fi

echo 'remove ubiquity file about wireless'
sudo chroot ${CHROOTDIR} /bin/bash -c "rm /usr/lib/ubiquity/plugins/ubi-wireless.py"
sudo chroot ${CHROOTDIR} /bin/bash -c "rm /usr/lib/ubiquity/plugins/__pycache__/ubi-wireless.cpython-33.pyc"


sudo chroot ${CHROOTDIR} /bin/bash -c "cp /usr/share/zoneinfo/Asia/Shanghai /usr/share/zoneinfo/Asia/Beijing"
sudo chroot ${CHROOTDIR} /bin/bash -c "cd /usr/share/zoneinfo/posix/Asia && ln -s ../../Asia/Beijing Beijing"
sudo chroot ${CHROOTDIR} /bin/bash -c "cp /usr/share/zoneinfo/right/Asia/Shanghai /usr/share/zoneinfo/right/Asia/Beijing"

echo "modify ubiquity wireless and zoneinfo successfull~"
