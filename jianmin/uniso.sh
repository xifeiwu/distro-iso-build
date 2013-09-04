#!/bin/sh
ISOPATH=/home/j/Backup/linuxmint-15-cinnamon-dvd-32bit.iso

if [ "$USER" != "root" ] ; then
    echo "error: you are not run as root user, you should excute su ."
    exit
fi

echo warning:you should run as root. But be careful!

if [ ! -d mymint ] ; then
    if [ ! -e mintiso ] ; then
        echo mount iso to $PWD/mintiso
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
