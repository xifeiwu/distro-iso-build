#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$1
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo set default username for WPS, add $OUTPATH/squashfs-root/etc/skel/.config/Software/Kingsoft.conf
mypath=$OUTPATH/squashfs-root/etc/skel/.config/Software
if [ ! -x "$mypath" ] ; then
    mkdir $mypath
fi
cp $DISTURBPATH/tmpfiles/Kingsoft.conf $OUTPATH/squashfs-root/etc/skel/.config/Software/
