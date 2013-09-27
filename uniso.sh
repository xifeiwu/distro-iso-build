#!/bin/sh
set -e

if [ "$USER" != "root" ] ; then
    echo "error: you are not run as root user, you should excute sudo."
    exit -1
fi

if [ $# -lt 2 ] ; then
    echo You should execute this script with two param at least as follow:
    echo sh $0 ISOPATH OUTPATH
    exit -1
fi

if [ ! -f $1 ] ; then
    echo You should make sure the iso $1 is a file that exists
    exit -1
fi

if [ -e $2 ] ; then
    if [ ! -d $2 ] ; then
        echo You should make sure the outpath $2 is a dir
        exit -1
    fi
else
    mkdir $2
fi

ISOPATH=$1
OUTPATH=$(cd $2; pwd)

echo uniso.sh will export iso file to $OUTPATH, the dir tree like this:
echo +mkiso_out
echo \|---mymint---------------  The files contained in iso.
echo \|---initrd_lz------------  The files contained in iso/casper/initrd_lz
echo \\---squashfs-root--------  The files contained in iso/casper/filesystem.squashfs

if [ ! -d $OUTPATH/mymint ] ; then
    mkdir $OUTPATH/mymint

    if [ ! -e mintiso ] ; then
        echo mount iso to $OUTPATH/mintiso
        mkdir $OUTPATH/mintiso
        mount -o loop $ISOPATH $OUTPATH/mintiso
    else
        echo warning:mintiso has exist, it is expected iso has been mounted normally.
    fi

    echo copy iso/* to mymint, just wait for some minutes.
    cp -r $OUTPATH/mintiso/. $OUTPATH/mymint
    umount $OUTPATH/mintiso
    rmdir $OUTPATH/mintiso
else
    echo warning:mymint has exist, it is expected iso/* has been copied to mymint dir.
fi

cd $OUTPATH

if [ ! -e initrd_lz ] ; then
    echo gunzip initrd.lz
    mkdir initrd_lz
    cp mymint/casper/initrd.lz initrd.lz
    echo warning: now, it is supported the format of initrd.lz is gzip, not lzma. If it is lzma, you should change it.
    mv initrd.lz initrd.gz
    gunzip initrd.gz
    cd initrd_lz
    cpio -id<../initrd
    rm ../initrd
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
