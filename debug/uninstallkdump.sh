#卸载kdump工具相关软件包,把此脚本放在build/debug/路径下,把app目录放在～/app下
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

chroot ${CHROOTDIR} /bin/bash -c "dpkg -P libdw1 python3-problem-report python3-apport apport apport-symptoms crash makedumpfile kexec-tools kdump-tools linux-crashdump"

echo "Kdump uninstalled successful!"


