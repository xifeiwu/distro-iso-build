#!/bin/sh
#All patch is genereate by executing likely follow command.
#diff -uN ~/pcos/mymint_raw/squashfs-root/boot/grub/grub.cfg ~/pcos/mkiso_out/squashfs-root/boot/grub/grub.cfg > Patch_mymint_squashfs-root_boot_grub_grub_cfg.patch
set -e
if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$1
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

patch -d $OUTPATH -p0 < $DISTURBPATH/patch/Patch_mymint_boot_grub_loopback_cfg.patch
patch -d $OUTPATH -p0 < $DISTURBPATH/patch/Patch_mymint_disk_info.patch
patch -d $OUTPATH -p0 < $DISTURBPATH/patch/Patch_mymint_disk_mint4win.patch
patch -d $OUTPATH -p0 < $DISTURBPATH/patch/Patch_mymint_disk_release_notes_url.patch
patch -d $OUTPATH -p0 < $DISTURBPATH/patch/Patch_mymint_isolinux_isolinux_cfg.patch
patch -d $OUTPATH -p0 < $DISTURBPATH/patch/Patch_squashfs-root_usr_share_glib-2.0_schemas_org.cinnamon.gschema.xml.patch
patch -d $OUTPATH -p0 < $DISTURBPATH/patch/Patch_squashfs-root_boot_grub_grub_cfg.patch
patch -d $OUTPATH -p0 < $DISTURBPATH/patch/Patch_squashfs-root_usr_lib_ubiq_ubiq_misc_py.patch
patch -d $OUTPATH -p0 < $DISTURBPATH/patch/Patch_squashfs-root_usr_share_ubi-slide_slides_l10n_zhCN_welcome_html.patch
patch -d $OUTPATH -p0 < $DISTURBPATH/patch/Patch_squashfs-root_usr_share_ubi-slide_slides_welcome_html.patch
patch -d $OUTPATH -p0 < $DISTURBPATH/patch/Patch_squashfs-root_usr_share_ubi-slide_slides_index_html.patch

