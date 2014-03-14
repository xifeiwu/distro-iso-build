#卸载kdump工具相关软件包,把此脚本放在build/debug/路径下,把app目录放在～/app下
set -e

CHROOTDIR=~/customize/mkiso_out/squashfs-root
DEBDIR=~/cdos-oem

if [ -z "$1" ] ; then
    echo error: No chrootdir setting at first param.
    exit -1
fi

if [ -z "$2" ] ; then
    echo error: No deb dir setting at second param.
    exit -1
fi

CURDIR=$(cd "$(dirname $0)"; pwd)
. $CURDIR/../set_version.sh
isodir=$OSNAME
CHROOTDIR=$1/squashfs-root
CDOSDIR=$1/$isodir
DEBDIR=$2/cdos-oem

if [ ! -e "${CHROOTDIR}" ]; then
    echo "squashfs-root not found"
    exit
fi

chroot ${CHROOTDIR} /bin/bash -c "dpkg -P bogl-bterm tasksel tasksel-data ubiquity-frontend-debconf"
chroot ${CHROOTDIR} /bin/bash -c "rm -rf /usr/share/oem"

#replace preseed and linuxconf
rm ${CDOSDIR}/isolinux/isolinux.cfg
rm ${CDOSDIR}/preseed/cdos.seed
mv  ${DEBDIR}/isolinux.cfg ${CDOSDIR}/isolinux/isolinux.cfg
mv ${DEBDIR}/cdos.seed ${CDOSDIR}/preseed/cdos.seed

#replace user-setup-apply
rm ${CHROOTDIR}/usr/lib/ubiquity/user-setup/user-setup-apply
mv ${DEBDIR}/user-setup-apply ${CHROOTDIR}/usr/lib/ubiquity/user-setup/user-setup-apply

echo "Oem uninstall successful!"


