#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

run_patch(){
set +e
patch --dry-run -N $*
ERROR=$?
set -e
if [ $ERROR -eq 0 ] ; then
    patch -N $*
else
    patch -R -N $*
    patch -N $*
fi
}

OUTPATH=$(cd $1; pwd)
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo "Reconfig start menu..."

applicationPath=$OUTPATH/squashfs-root/usr/share/applications
if [ ! -x "$applicationPath" ] ; then
    echo "The applications directory does not exist!"
    exit -1
fi
cd $OUTPATH/squashfs-root/usr/share
run_patch -p0 -i $DISTURBPATH/tmpfiles/applications.patch
echo "Patch applications directory successfully!"

#directoryPath=$OUTPATH/squashfs-root/usr/share/desktop-directories
#if [ ! -x "$directoryPath" ] ; then
#    echo "The desktop directory does not exist!"
#    exit -1
#fi
#cd $OUTPATH/squashfs-root/usr/share
#run_patch -p0 -i $DISTURBPATH/tmpfiles/desktop-directories.patch
#echo "Patch desktop directory successfully!"

mdmApplicationsPath=$OUTPATH/squashfs-root/usr/share/mdm/applications
if [ ! -x "$mdmApplicationsPath" ] ; then
    echo "The mdm applications directory does not exist!"
    exit -1
fi
cd $OUTPATH/squashfs-root/usr/share
run_patch -p0 -i $DISTURBPATH/tmpfiles/mdm_applications.patch
echo "Patch mdm applications directory successfully!"

cp $DISTURBPATH/tmpfiles/yelp.desktop $OUTPATH/squashfs-root/usr/share/ubuntu-system-adjustments/yelp/
echo "Reconfig help menu succefully!"

#cp $DISTURBPATH/tmpfiles/org.cinnamon.gschema.xml $OUTPATH/squashfs-root/usr/share/glib-2.0/schemas/
echo "Reconfig favorite menu succefully!"
cp $DISTURBPATH/tmpfiles/icon.png $OUTPATH/squashfs-root/usr/lib/linuxmint/mintInstall/
echo "Reconfig software center icon succefully!"

#Here we will reconfig software sources...
if [ ! -x $DISTURBPATH/tmpfiles/Iceblue ] ; then
    echo "The config file of software source does not exist!"
    exit -1
fi
cp -r $DISTURBPATH/tmpfiles/Iceblue $OUTPATH/squashfs-root/usr/share/mintsources/
echo "Set up software sources succefully!"

#change start menu icon
echo change squashfs-root/usr/share/cinnamon/theme/menu.png
cp -f $DISTURBPATH/materials/menu.png $OUTPATH/squashfs-root/usr/share/cinnamon/theme/
echo "Menu icon changed!"

echo "Reconfig start menu successfully!"

