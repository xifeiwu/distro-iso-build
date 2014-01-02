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

SQUASHFS=$1
OUTPATH=$(cd $2; pwd)

echo uniso.sh will export iso $SQUASHFS file to $OUTPATH, the dir tree like this:
echo +mkiso_out
echo \\---squashfs-root--------  The files contained in filesystem.squashfs

if [ ! -d $OUTPATH/mycos ] ; then
    mkdir $OUTPATH/mycos

    mkdir $OUTPATH/mycos/casper
    cd $OUTPATH
    if [ ! -e squashfs-root ] ; then
        echo unsquashfs mycos/casper/filesystem.squashfs
        echo just wait for some minutes.
        unsquashfs $SQUASHFS
    else
        echo warning:squashfs-root has exist, it is expected filesystem.squashfs has been executed unsquashfs normally.    
    fi
else
    echo warning:mycos has exist, it is expected iso/* has been copied to mycos dir.
fi

#wangyu:Copy vmlinuz and initrd.lz to casper, to make sure user can excute mkiso without customization.
sudo cp $OUTPATH/squashfs-root/boot/vmlinuz-3.8.0-19-generic $OUTPATH/mycos/casper/vmlinuz
sudo cp $OUTPATH/squashfs-root/boot/initrd.img-3.8.0-19-generic $OUTPATH/mycos/casper/initrd.lz

#if [ ! -e initrd_lz ] ; then
#    echo gunzip initrd.lz
#    mkdir initrd_lz
#    cp mycos/casper/initrd.lz initrd.lz
#    echo warning: now, it is supported the format of initrd.lz is gzip, not lzma. If it is lzma, you should change it.
#    mv initrd.lz initrd.gz
#    gunzip initrd.gz
#    cd initrd_lz
#    cpio -id<../initrd
#    rm ../initrd
#    cd ..
#else
#    echo warning: initrd_lz has exist, it is expected initrd.lz has been decompressed normally.
#fi

echo uniso has finished.
