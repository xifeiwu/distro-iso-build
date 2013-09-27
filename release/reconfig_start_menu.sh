#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$1
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo "Reconfig start menu..."

applicationPath=$OUTPATH/squashfs-root/usr/share/applications
if [ ! -x "$applicationPath" ] ; then
    echo "The applications directory does not exist!"
    exit -1
fi
cd $OUTPATH/squashfs-root/usr/share
patch -p0 < $DISTURBPATH/tmpfiles/applications.patch
echo "Patch applications directory successfully!"

directoryPath=$OUTPATH/squashfs-root/usr/share/desktop-directories
if [ ! -x "$directoryPath" ] ; then
    echo "The desktop directory does not exist!"
    exit -1
fi
cd $OUTPATH/squashfs-root/usr/share
patch -p0 < $DISTURBPATH/tmpfiles/desktop-directories.patch
echo "Patch desktop directory successfully!"

mdmApplicationsPath=$OUTPATH/squashfs-root/usr/share/mdm/applications
if [ ! -x "$mdmApplicationsPath" ] ; then
    echo "The mdm applications directory does not exist!"
    exit -1
fi
cd $OUTPATH/squashfs-root/usr/share
patch -p0 < $DISTURBPATH/tmpfiles/mdm_applications.patch
echo "Patch mdm applications directory successfully!"

cp $DISTURBPATH/tmpfiles/yelp.desktop $OUTPATH/squashfs-root/usr/share/ubuntu-system-adjustments/yelp/
echo "Reconfig help menu succefully!"

cp $DISTURBPATH/tmpfiles/org.cinnamon.gschema.xml $OUTPATH/squashfs-root/usr/share/glib-2.0/schemas/
echo "Reconfig favorite menu succefully!"

cp $DISTURBPATH/tmpfiles/icon.png $OUTPATH/squashfs-root/usr/lib/linuxmint/mintInstall/
echo "Reconfig software center icon succefully!"

echo "Reconfig start menu successfully!"

