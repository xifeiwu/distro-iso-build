#!/bin/sh
OUTPATH=$PWD/mkiso_out

if [ -z "$1" ] ; then
    echo "error: you should input path as first parameter. 
    echo Just as: sh custom.sh path/to/material"
    exit
fi
MATERIALPATH=$1
#"./materials"

echo warning:you should run as root. But be careful!

if [ "$USER" != "root" ] ; then
    echo "error: you are not run as root user, you should excute sudo."
    exit
fi

echo "custom initrd."
if [ ! -e ${OUTPATH}/initrd_lz ]; then
    echo "initrd_lz not found"
    exit
fi
INITRDLOGO=${OUTPATH}/initrd_lz/lib/plymouth/themes
cp ${MATERIALPATH}/bootlogo.png ${MATERIALPATH}/shutlogo.png ${INITRDLOGO}/mint-logo
patch ${INITRDLOGO}/text.plymouth ${MATERIALPATH}/text.patch
patch ${INITRDLOGO}/mint-text/mint-text.plymouth ${MATERIALPATH}/text.patch


if [ ! -e ${OUTPATH}/squashfs-root ]; then
    echo "squashfs-root not found"
    exit
fi
cp ${MATERIALPATH}/* ./mkiso_out/squashfs-root/media
deblist=`ls ${MATERIALPATH} | grep .deb`
cd ${OUTPATH}
sudo chroot squashfs-root /bin/bash -c "mount none  /proc -t proc"
for file in $deblist
do
    #echo ${file}
    sudo chroot squashfs-root /bin/bash -c "dpkg -i /media/${file}"
done
sudo chroot squashfs-root /bin/bash -c "umount /proc/"

sudo chroot squashfs-root /bin/bash -c "cp /media/lsb-release /media/issue /media/issue.net /etc/"
sudo chroot squashfs-root /bin/bash -c "rm /media/*"
