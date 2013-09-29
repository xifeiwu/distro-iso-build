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

echo patching org.cinanmon.gschemas.xml
cd $DISTURBPATH/patch_slides
set +e
diff -uN slides_raw slides >/tmp/new.patch
set -e
run_patch -p0 -d $OUTPATH/squashfs-root/usr/share/ubiquity-slideshow -i /tmp/new.patch
rm /tmp/new.patch
echo finished.
