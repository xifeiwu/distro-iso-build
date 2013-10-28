#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$1
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo change squashfs-root/usr/share/ubiquity-slideshow/slides/screenshots/welcome.png
cp $DISTURBPATH/ubiquity-slideshow/slides/screenshots/help.png $OUTPATH/squashfs-root/usr/share/ubiquity-slideshow/slides/screenshots
