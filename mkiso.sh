#!/bin/sh
set -e

OUTPATH=$PWD/mkiso_out
ISONAME="mycos-i386-`date +%Y%m%d%H%M`.iso"
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

cd $OUTPATH

if [ ! -e mycos ] ; then
    echo error: mycos does not exist. exit.
    exit -1
fi

if [ ! -e mycos/casper ] ; then
    echo error: mycos/casper does not exist. exit.
    exit -1
fi

#if [ ! -e initrd_lz ] ; then
#    echo error: initrd_lz does not exist. exit.
#    exit -1
#fi

if [ ! -e squashfs-root ] ; then
    echo error: squashfs-root does not exist. exit.
    exit -1
fi

echo change casper username and hostname
sed -i 's/mint/cos/' $OUTPATH/squashfs-root/etc/casper.conf
echo success changing casper username and hostname

echo mkiso.sh will generate iso file $ISONAME in $GENISOPATH.

echo generate manifest.
chroot squashfs-root dpkg-query -W --showformat='${Package} ${Version}\n' > mycos/casper/filesystem.manifest
cp mycos/casper/filesystem.manifest mycos/casper/filesystem.manifest-desktop
sed -i '/ubiquity/d' mycos/casper/filesystem.manifest-desktop
sed -i '/casper/d' mycos/casper/filesystem.manifest-desktop
sed -i '/libdebian-installer/d' mycos/casper/filesystem.manifest-desktop
sed -i '/user-setup/d' mycos/casper/filesystem.manifest-desktop
printf $(sudo du -sx --block-size=1 . | cut -f1) > mycos/casper/filesystem.size

#echo gzip initrd
#cd initrd_lz
#if [ -f initrd ] ; then
#    rm initrd
#fi
#find . | cpio --quiet --dereference -o -H newc>./initrd
#gzip initrd
#mv initrd.gz ../mycos/casper/initrd.lz
#cd ..

echo mksquashfs
rm -rf mycos/casper/filesystem.squashfs
mksquashfs squashfs-root mycos/casper/filesystem.squashfs 

echo gen md5sum
cd mycos
find . -type f -print0 | xargs -0 md5sum > MD5SUMS
find . -type f -print0 | xargs -0 md5sum > md5sum.txt
cd ..

echo  mkisofs
cd mycos
mkisofs -r -V "COS Desktop" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "$GENISOPATH/$ISONAME" .
echo mkiso has finished.
cd ..
ls -l $GENISOPATH/$ISONAME
echo you can test this iso by executing the command as follows:
echo kvm -m 512 -cdrom $GENISOPATH/$ISONAME -boot order=d
