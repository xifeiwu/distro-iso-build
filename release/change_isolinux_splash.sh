#!/bin/sh

OUTPATH=/home/j/pcos/mkiso_out
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo change mymint/isolinux/splash.png
cp $DISTURBPATH/isolinux/splash.jpg $OUTPATH/mymint/isolinux/splash.jpg
