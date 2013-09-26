#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$1

DISTURBPATH=$(cd "$(dirname $0)"; pwd)

MATERIALPATH=$DISTURBPATH/materials

if [ ! -d $MATERIALPATH ] ; then
    echo error: materials path is not exist, you should set it correctly. Wrong PATH:$MATERIALPATH
    exit
fi

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

run_patch(){
set +e
patch --dry-run -N $*
ERROR=$?
set -e
echo error:$ERROR.
if [ $ERROR -eq 0 ] ; then
    patch $*
else
    patch -R $*
    patch $*
fi
}

INITRDLOGO=${OUTPATH}/initrd_lz/lib/plymouth/themes
cp ${MATERIALPATH}/bootlogo.png ${MATERIALPATH}/shutlogo.png ${INITRDLOGO}/mint-logo
run_patch ${INITRDLOGO}/text.plymouth ${MATERIALPATH}/text.patch
run_patch ${INITRDLOGO}/mint-text/mint-text.plymouth ${MATERIALPATH}/text.patch


if [ ! -e ${OUTPATH}/squashfs-root ]; then
    echo "squashfs-root not found"
    exit
fi
cp -r ${MATERIALPATH}/* $OUTPATH/squashfs-root/media
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
sudo chroot squashfs-root /bin/bash -c "rm -rf /media/*"
