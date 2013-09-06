#!/bin/sh
#change back_ground /usr/share/backgrounds/linuxmint-olivia

OUTPATH=/home/j/pcos/mkiso_out
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo change mymint/isolinux/splash.png
cp $DISTURBPATH/isolinux/splash.jpg $OUTPATH/mymint/isolinux/splash.jpg

echo change mymint/isolinux/isolinux.cfg
cd $OUTPATH
patch -p0 < $DISTURBPATH/isolinux/isolinux.cfg.patch
