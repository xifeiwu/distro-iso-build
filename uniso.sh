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

echo $SQUASHFS | grep -E "\.iso$" >/dev/null && ISISO=1 || ISISO=0
echo $SQUASHFS | grep -E "\.squashfs$" >/dev/null && ISSQUASHFS=1 || ISSQUASHFS=0
if [ $ISISO -eq 1 ] ; then
#=========================
#uniso begin

echo uniso.sh will export iso $ISOPATH file to $OUTPATH, the dir tree like this:
echo +out
echo \|---mycos---------------  The files contained in iso.
echo \\---squashfs-root--------  The files contained in iso/casper/filesystem.squashfs

if [ ! -d $OUTPATH/mycos ] ; then
    mkdir $OUTPATH/mycos

    if [ ! -e mintiso ] ; then
        echo mount iso to $OUTPATH/mintiso
        mkdir $OUTPATH/mintiso
        mount -o loop $SQUASHFS $OUTPATH/mintiso
    else
        echo warning:mintiso has exist, it is expected iso has been mounted normally.
    fi

    echo copy iso/casper to mycos, just wait for some minutes.
    mkdir $OUTPATH/mycos/casper
    cp $OUTPATH/mintiso/casper/initrd.lz $OUTPATH/mycos/casper/
    cp $OUTPATH/mintiso/casper/vmlinuz $OUTPATH/mycos/casper/
    cd $OUTPATH
    if [ ! -e squashfs-root ] ; then
        echo unsquashfs mycos/casper/filesystem.squashfs
        echo just wait for some minutes.
        unsquashfs $OUTPATH/mintiso/casper/filesystem.squashfs
    else
        echo warning:squashfs-root has exist, it is expected filesystem.squashfs has been executed unsquashfs normally.    
    fi
    umount $OUTPATH/mintiso
    rmdir $OUTPATH/mintiso
else
    echo warning:mycos has exist, it is expected iso/* has been copied to mycos dir.
fi

#uniso end
#=========================
elif [ $ISSQUASHFS -eq 1 ] ; then
#=========================
#unsquashfs begin

echo uniso.sh will export iso $SQUASHFS file to $OUTPATH, the dir tree like this:
echo +out
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
    echo warning:mycos has exist, it is expected squashfs file has been unsquashfsed to mycos dir.
fi

#wangyu:Copy vmlinuz and initrd.lz to casper, to make sure user can excute mkiso without customization.
sudo cp $OUTPATH/squashfs-root/boot/vmlinuz-3.8.0-19-generic $OUTPATH/mycos/casper/vmlinuz
sudo cp $OUTPATH/squashfs-root/boot/initrd.img-3.8.0-19-generic $OUTPATH/mycos/casper/initrd.lz

#unsquashfs end
#=========================
else
    echo ERROR: this file $ISOPATH can not be supported for not iso or squashfs file.
    exit -1
fi

echo uniso has finished.

