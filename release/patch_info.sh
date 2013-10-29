#!/bin/sh
#All patch is genereate by executing likely follow command.
#diff -uN ~/pcos/mymint_raw/squashfs-root/boot/grub/grub.cfg ~/pcos/mkiso_out/squashfs-root/boot/grub/grub.cfg > Patch_mymint_squashfs-root_boot_grub_grub_cfg.patch
set -e
if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

run_patch(){
set +e
patch --dry-run -N $*
ERROR=$?
set -e
echo error:$ERROR.
if [ $ERROR -eq 0 ] ; then
    patch -N $*
else
    patch -R -N $*
    patch -N $*
fi
}

OUTPATH=$(cd $1; pwd)
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

run_patch -d $OUTPATH -p0 -i $DISTURBPATH/patch/Patch_mymint_boot_grub_loopback_cfg.patch
run_patch -d $OUTPATH -p0 -i $DISTURBPATH/patch/Patch_mymint_disk_info.patch
run_patch -d $OUTPATH -p0 -i $DISTURBPATH/patch/Patch_mymint_disk_mint4win.patch
run_patch -d $OUTPATH -p0 -i $DISTURBPATH/patch/Patch_mymint_disk_release_notes_url.patch
run_patch -d $OUTPATH -p0 -i $DISTURBPATH/patch/Patch_mymint_isolinux_isolinux_cfg.patch
