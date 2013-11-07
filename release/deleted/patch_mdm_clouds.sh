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
if [ $ERROR -eq 0 ] ; then
    patch -N $*
else
    patch -R -N $*
    patch -N $*
fi
}

OUTPATH=$(cd $1; pwd)
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo patching /usr/share/mdm/html-themes/Clouds/index.html
cd $DISTURBPATH/mdm_clouds
set +e
diff -uN Clouds_raw Clouds >/tmp/patch_mdm_clouds.patch
set -e
run_patch -p0 -d $OUTPATH/squashfs-root/usr/share/mdm/html-themes -i /tmp/patch_mdm_clouds.patch
rm /tmp/patch_mdm_clouds.patch
echo finished.
