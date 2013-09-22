#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param in change menu icon.
    exit -1
fi

OUTPATH=$1
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo change squashfs-root/usr/share/cinnamon/theme/menu.png
cp -f $DISTURBPATH/materials/menu.png $OUTPATH/squashfs-root/usr/share/cinnamon/theme/
echo "Menu icon changed!"

echo change squashfs-root/usr/share/glib-2.0/schemas/org.cinnamon.gschema.xml
cp -f $DISTURBPATH/materials/org.cinnamon.gschema.xml $OUTPATH/squashfs-root/usr/share/glib-2.0/schemas/
echo "Menu title changed!"
