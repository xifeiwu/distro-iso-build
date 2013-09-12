#!/bin/sh
set -e

OUTPATH=$PWD/mkiso_out
ISONAME="mymint-1.0-i386-`date +%Y%m%d%H%M`.iso"
echo warning:you should run as root. But be careful!

if [ "$USER" != "root" ] ; then
    echo "error: you are not run as root user, you should excute sudo."
    exit -1
fi

if [ ! -d $OUTPATH ] ; then
    echo error: $OUTPATH does not exist. exit.
    exit -1
fi

cd $OUTPATH

if [ ! -e mymint ] ; then
    echo error: mymint does not exist. exit.
    exit -1
fi

if [ ! -e mymint/casper ] ; then
    echo error: mymint/casper does not exist. exit.
    exit -1
fi

if [ ! -e initrd_lz ] ; then
    echo error: initrd_lz does not exist. exit.
    exit -1
fi

if [ ! -e squashfs-root ] ; then
    echo error: squashfs-root does not exist. exit.
    exit -1
fi

echo mkiso.sh will generate iso file $ISONAME in $OUTPATH.

echo generate manifest.
chroot squashfs-root dpkg-query -W --showformat='${Package} ${Version}\n' > mymint/casper/filesystem.manifest
cp mymint/casper/filesystem.manifest mymint/casper/filesystem.manifest-desktop

echo gzip initrd
cd initrd_lz
find . | cpio --quiet --dereference -o -H newc>./initrd
gzip initrd
mv initrd.gz ../mymint/casper/initrd.lz
cd ..

echo mksquashfs
rm -rf mymint/casper/filesystem.squashfs
mksquashfs squashfs-root mymint/casper/filesystem.squashfs 

echo gen md5sum
cd mymint
find . -type f -print0 | xargs -0 md5sum > md5sum.txt
cd ..

echo  mkisofs
cd mymint
mkisofs -r -V "mymint" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "../$ISONAME" .
echo mkiso has finished.
cd ..
ls -l $ISONAME
echo you can test this iso by executing the command kvm -m 512 -cdrom $PWD/$ISONAME boot order=d
