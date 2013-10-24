#!/bin/sh
#All patch is genereate by executing likely follow command.
#diff -uN ~/pcos/mymint_raw/squashfs-root/boot/grub/grub.cfg ~/pcos/mkiso_out/squashfs-root/boot/grub/grub.cfg > Patch_mymint_squashfs-root_boot_grub_grub_cfg.patch
set -e
if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$(cd $1; pwd)
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo patching cinnamon settings locale zh_CN
msgfmt $DISTURBPATH/cinnamon_locale/cinnamon.po -o $OUTPATH/squashfs-root/usr/share/cinnamon/locale/zh_CN/LC_MESSAGES/cinnamon.mo
echo finished.
