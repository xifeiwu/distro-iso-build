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

cp ${MATERIALPATH}/* ./mkiso_out/squashfs-root/media
deblist=`ls ${MATERIALPATH} | grep .deb`

cd ${OUTPATH}
if [ ! -e squashfs-root ]; then
    echo "squashfs-root not found"
    exit
fi

sudo chroot squashfs-root /bin/bash -c "mount none  /proc -t proc"
for file in $deblist
do
    #echo ${file}
    sudo chroot squashfs-root /bin/bash -c "dpkg -i /media/${file}"
done
sudo chroot squashfs-root /bin/bash -c "umount /proc/"

sudo chroot squashfs-root /bin/bash -c "cp /media/lsb-release /media/issue /media/issue.net /etc/"
sudo chroot squashfs-root /bin/bash -c "rm /media/*"
