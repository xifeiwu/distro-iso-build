#!/bin/sh
#change back_ground /usr/share/backgrounds/linuxmint-olivia

OUTPATH=/home/j/pcos/mkiso_out
DISTURBPATH=`dirname $0`

echo change mymint/isolinux/splash.png
cp $DISTURBPATH/isolinux/splash.jpg $OUTPATH/mymint/isolinux/splash.jpg

echo change mymint/isolinux/isolinux.cfg
cp $DISTURBPATH/isolinux/isolinux.cfg $OUTPATH/mymint/isolinux/isolinux.cfg
