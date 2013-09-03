#!/bin/sh
ISOPATH=/home/j/Backup/linuxmint-15-cinnamon-dvd-32bit.iso
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

if [ ! -e squashfs-root ] ; then
    echo unsquashfs mymint/casper/filesystem.squashfs
    echo just wait for some minutes.
    unsquashfs mymint/casper/filesystem.squashfs
else
    echo warning:squashfs-root has exist, it is expected filesystem.squashfs has been executed unsquashfs normally.    
fi

