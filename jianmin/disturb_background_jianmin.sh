#!/bin/sh
#change back_ground /usr/share/backgrounds/linuxmint-olivia

OUTPATH=/home/j/pcos/mkiso_out
DISTURBPATH=$(cd "$(dirname $0)"; pwd)


CHROOTDIR=$OUTPATH/squashfs-root

echo change /usr/share/backgrounds/linuxmint-olivia
cp $DISTURBPATH/backgrounds/cos_desktop.png $OUTPATH/squashfs-root/usr/share/backgrounds/linuxmint-olivia/
chroot $CHROOTDIR /bin/bash -c "rm /usr/share/backgrounds/linuxmint/default_background.jpg && cd /usr/share/backgrounds/linuxmint/ && ln -s ../linuxmint-olivia/cos_desktop.png /usr/share/backgrounds/linuxmint/default_background.jpg"
