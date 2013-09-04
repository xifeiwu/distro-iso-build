#!/bin/sh
OUTPATH=$PWD/mkiso_out
echo warning:you should run as root and make sure you have executed su root. But be careful!
echo warning:sudo is not supported.

if [ "$USER" != "root" ] ; then
    echo "error: you are not run as root user, you should excute su ."
    exit
fi

if [ -z "$1" ] ; then
    echo "error: you should input isopath as first parameter. 
    echo Just as: sh mkiso.sh filename.iso"
    exit
fi

ISOPATH=$1

if [ ! -f $ISOPATH ] ; then
    echo error: iso is not exist, you should set it correctly. Wrong ISOPATH:$ISOPATH
    exit
fi

echo uniso.sh will export iso file to $OUTPATH, the dir tree like this:
echo +mkiso_out
echo \|---mymint---------------  The files contained in iso.
echo \|---initrd_lz------------  The files contained in iso/casper/initrd_lz
echo \\---squashfs-root--------  The files contained in iso/casper/filesystem.squashfs

if [ ! -d $OUTPATH ] ; then
    mkdir $OUTPATH
fi

cd $OUTPATH

if [ ! -d mymint ] ; then
    if [ ! -e mintiso ] ; then
        echo mount iso to $OUTPATH/mintiso
        mkdir mintiso
        mount -o loop $ISOPATH mintiso
    else
        echo warning:mintiso has exist, it is expected iso has been mounted normally.
    fi

    echo copy iso/* to mymint, just wait for some minutes.
    mkdir mymint
    cp -r mintiso/. mymint
    umount mintiso
    rmdir mintiso
else
    echo warning:mymint has exist, it is expected iso/* has been copied to mymint dir.
fi

if [ ! -e initrd_lz ] ; then
    echo lzma initrd.lz
    mkdir initrd_lz
    cp mymint/casper/initrd.lz initrd_lz/initrd.lz
    echo warning: now, it is supported the format of initrd.lz is gzip, not lzma. If it is lzma, you should change it.
    cd initrd_lz
    mv initrd.lz initrd.gz
    gunzip initrd.gz
    cpio -id<./initrd
    cd ..
else
    echo warning: initrd_lz has exist, it is expected initrd.lz has been decompressed normally.
fi

if [ ! -e squashfs-root ] ; then
    echo unsquashfs mymint/casper/filesystem.squashfs
    echo just wait for some minutes.
    unsquashfs mymint/casper/filesystem.squashfs
else
    echo warning:squashfs-root has exist, it is expected filesystem.squashfs has been executed unsquashfs normally.    
fi

echo uniso has finished.
