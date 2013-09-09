#!/bin/sh

OUTPATH=/home/j/pcos/mkiso_out
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo change squashfs-root/usr/share/ubiquity-slideshow/slides/screenshots/welcome.png
cp $DISTURBPATH/ubiquity-slideshow/slides/screenshots/welcome.png $OUTPATH/squashfs-root/usr/share/ubiquity-slideshow/slides/screenshots
