#!/bin/sh
#All patch is genereate by executing follow command.
#diff -uN ~/pcos/mymint_raw/squashfs-root/boot/grub/grub.cfg ~/pcos/mkiso_out/squashfs-root/boot/grub/grub.cfg > Patch_mymint_squashfs-root_boot_grub_grub_cfg.patch
set -e
if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$1
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

patch -d $OUTPATH -p0 < $DISTURBPATH/patch/applications1.patch
patch -d $OUTPATH -p0 < $DISTURBPATH/patch/applications2.patch

