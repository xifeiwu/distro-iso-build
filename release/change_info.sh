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
. $DISTURBPATH/set_version.sh

echo Generate some info file in iso.
echo COS Desktop $COSVERSION "$COSVERSIONNAME" - Release i386 \(`date +%Y%m%d`\)>$OUTPATH/mymint/.disk/info
echo COS Desktop $COSVERSION "$COSVERSIONNAME" - Release i386 \(`date +%Y%m%d`\)>$OUTPATH/mymint/.disk/mint4win
echo www.iscas.ac.cn>$OUTPATH/mymint/.disk/release_notes_url
sed -i 's/Linux Mint/COS Desktop/' $OUTPATH/mymint/boot/grub/loopback.cfg
sed -i 's/Linux Mint 15 Cinnamon/COS Desktop "$COSVERSION"/' $OUTPATH/mymint/isolinux/isolinux.cfg
sed -i 's/Linux Mint/COS Desktop/' $OUTPATH/mymint/isolinux/isolinux.cfg
echo Success generating info file.
