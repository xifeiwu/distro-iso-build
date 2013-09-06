#!/bin/sh
#change back_ground /usr/share/backgrounds/linuxmint-olivia

OUTPATH=/home/j/pcos/mkiso_out
DISTURBPATH=`dirname $0`

echo change initrd_lz/lib/plymouth/ubuntu_logo.png
cp $DISTURBPATH/initrd_lz/lib/plymouth/ubuntu_logo.png $OUTPATH/initrd_lz/lib/plymouth/ubuntu_logo.png

echo change initrd_lz/lib/plymouth/themes/mint-logo/*.png
cp $DISTURBPATH/initrd_lz/lib/plymouth/themes/mint-logo/*.png $OUTPATH/initrd_lz/lib/plymouth/themes/mint-logo
