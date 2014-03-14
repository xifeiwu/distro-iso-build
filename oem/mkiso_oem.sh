#!/bin/sh
set -e

OUTPATH=$PWD/mkiso_out
echo warning:you should run as root. But be careful!

if [ "$USER" != "root" ] ; then
    echo "error: you are not run as root user, you should excute sudo."
    exit -1
fi

if [ $# -lt 2 ] ; then
    echo You should execute this script with two param at least as follow:
    echo sh $0 OUTPATH GENISOPATH
    exit -1
fi

if [ ! -d $1 ] ; then
    echo You should make sure the outpath $1 is a dir that exists
    exit -1
fi

if [ ! -d $2 ] ; then
    echo You should make sure the getisopath $2 is a dir that exists
    exit -1
fi


OUTPATH=$(cd $1; pwd)
GENISOPATH=$(cd $2; pwd)
SCRIPTPATH=$(cd "$(dirname $0)"; pwd)
. $SCRIPTPATH/../set_version.sh
ISONAME="$OSNAME-i386-`date +%Y%m%d%H%M`.iso"
if [ $# -gt 2 ] ; then
    ISONAME=$3
fi

cd $OUTPATH

if [ ! -e $OSNAME ] ; then
    echo error: $OSNAME does not exist. exit.
    exit -1
fi

if [ ! -e $OSNAME/casper ] ; then
    echo error: $OSNAME/casper does not exist. exit.
    exit -1
fi

if [ ! -e $OSNAME/casper/initrd.lz ] ; then
    echo error: initrd.lz does not exist. exit.
    exit -1
fi

if [ ! -e squashfs-root ] ; then
    echo error: squashfs-root does not exist. exit.
    exit -1
fi

echo mkiso.sh will generate iso file $ISONAME in $GENISOPATH.

echo generate manifest.
chroot squashfs-root dpkg-query -W --showformat='${Package} ${Version}\n' > $OSNAME/casper/filesystem.manifest
cp $OSNAME/casper/filesystem.manifest $OSNAME/casper/filesystem.manifest-desktop
#sed -i '/ubiquity/d' $OSNAME/casper/filesystem.manifest-desktop
#sed -i '/casper/d' $OSNAME/casper/filesystem.manifest-desktop
#sed -i '/libdebian-installer/d' $OSNAME/casper/filesystem.manifest-desktop
#sed -i '/user-setup/d' $OSNAME/casper/filesystem.manifest-desktop
printf $(sudo du -sx --block-size=1 . | cut -f1) > $OSNAME/casper/filesystem.size
sudo chroot $OUTPATH/squashfs-root /bin/bash -c "cd /home && rm -rf *"

#echo gzip initrd
#cd initrd_lz
#if [ -f initrd ] ; then
#    rm initrd
#fi
#find . | cpio --quiet --dereference -o -H newc>./initrd
#gzip initrd
#mv initrd.gz ../$OSNAME/casper/initrd.lz
#cd ..

echo mksquashfs
rm -rf $OSNAME/casper/filesystem.squashfs
mksquashfs squashfs-root $OSNAME/casper/filesystem.squashfs 

echo gen md5sum
cd $OSNAME
find . -type f -print0 | xargs -0 md5sum > MD5SUMS
find . -type f -print0 | xargs -0 md5sum > md5sum.txt
cd ..

echo  mkisofs
cd $OSNAME
mkisofs -r -V "$OSFULLNAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "$GENISOPATH/$ISONAME" .
echo mkiso has finished.
cd ..
ls -l $GENISOPATH/$ISONAME
echo you can test this iso by executing the command as follows:
echo kvm -m 512 -cdrom $GENISOPATH/$ISONAME -boot order=d
