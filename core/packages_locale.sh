#!/bin/sh
#set -e

if [ $# -eq 2 ] ; then
    MATERIALDIR=$1
    WORKDIR=$2
else
    echo You should execute this script with three param at least as follow:
    echo sh $0 MATERIALDIR WORKDIR
    exit -1
fi

cd ${WORKDIR}
chroot squashfs-root /bin/bash -c "[ -e /proc/mounts ] && umount /proc/"
chroot squashfs-root /bin/bash -c "mount none /proc -t proc"

chroot squashfs-root /bin/bash -c "dpkg --purge ubuntu-system-adjustments mint-mdm-themes mint-local-repository mint-meta-codecs mint-flashplugin mint-flashplugin-11 mint-meta-cinnamon mint-meta-core mint-search-addon mint-stylish-addon mintdrivers mint-artwork-cinnamon mintsources mintbackup mintstick mintwifi mint-artwork-gnome mint-artwork-common mint-backgrounds-olivia mint-x-icons mintsystem mintwelcome mintinstall mintinstall-icons mintnanny mintupdate mintupload mint-info-cinnamon mint-common mint-mirrors mint-translations"
chroot squashfs-root /bin/bash -c "dpkg --force-all --purge mint-themes"

chroot squashfs-root /bin/bash -c "cd appbuilt && dpkg -i ubuntu-system-adjustments_*.deb cos-mdm-themes*.deb cos-local-repository*.deb cos-meta-codecs*.deb cos-flashplugin*.deb cos-flashplugin-11*.deb cos-meta-cinnamon*.deb cos-meta-core*.deb cos-stylish-addon*.deb cosdrivers*.deb cos-artwork-cinnamon*.deb cossources*.deb cosbackup*.deb cosstick*.deb coswifi*.deb cos-artwork-gnome*.deb cos-themes*.deb cos-artwork-common*.deb cos-backgrounds-iceblue*.deb cos-x-icons*.deb cossystem*.deb coswelcome*.deb cosinstall*.deb cosinstall-icons*.deb cosnanny*.deb cosupdate*.deb cosupload*.deb cos-info-iceblue*.deb cos-common*.deb cos-mirrors*.deb cos-translations*.deb"
chroot squashfs-root /bin/bash -c "cd appbuilt && dpkg -i cinnamon_*.deb cinnamon-common_*.deb cinnamon-screensaver_*.deb nemo_*.deb nemo-data_*.deb nemo-share_*.deb"
chroot squashfs-root /bin/bash -c "cd appbuilt && dpkg -i cos-upgrade_*.deb"
chroot squashfs-root /bin/bash -c "umount /proc/"
