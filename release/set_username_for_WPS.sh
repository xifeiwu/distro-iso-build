#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

if [ -z "$2" ] ; then
    echo error: No deb dir setting at second param.
    exit -1
fi

DISTURBPATH=$(cd "$(dirname $0)"; pwd)
OUTPATH=$1
DEBDIR=$2

echo set default username for WPS, add $OUTPATH/squashfs-root/etc/skel/.config/Software/Kingsoft.conf
mypath=$OUTPATH/squashfs-root/etc/skel/.config/Software
if [ ! -x "$mypath" ] ; then
    mkdir $mypath
fi
cp $DISTURBPATH/tmpfiles/Kingsoft.conf $OUTPATH/squashfs-root/etc/skel/.config/Software/

mkdir $OUTPATH/squashfs-root/app
cp ${DEBDIR}/symbol-fonts_1.2_all.deb -a ${OUTPATH}/squashfs-root/app/
#安装wps所需字体，该字体版权属于微软
chroot $OUTPATH/squashfs-root /bin/bash -c "cd app && dpkg -i -E symbol-fonts_1.2_all.deb"
chroot $OUTPATH/squashfs-root /bin/bash -c "rm -rf app"

echo "Kingsoft.conf and wps-fonts installed successful!"
