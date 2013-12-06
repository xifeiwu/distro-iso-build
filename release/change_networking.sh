#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$1

echo Change networking to networking-deprecated.
if [ -f $OUTPATH/squashfs-root/etc/init/ufw.conf ] ; then
    sudo sed -i "s/ networking)/ networking-deprecated)/" $OUTPATH/squashfs-root/etc/init/ufw.conf
fi

if [ -f $OUTPATH/squashfs-root/etc/init/network-interface-security.conf ] ; then
    sudo sed -i "s/ networking)/ networking-deprecated)/" $OUTPATH/squashfs-root/etc/init/network-interface-security.conf
    sudo sed -i "s/stopped networking /stopped networking-deprecated /" $OUTPATH/squashfs-root/etc/init/network-interface-security.conf
fi

if [ -f $OUTPATH/squashfs-root/etc/init/networking.conf ] ; then
    sudo cp $OUTPATH/squashfs-root/etc/init/networking.conf $OUTPATH/squashfs-root/etc/init/networking-deprecated.conf
    sudo sed -i "s/ networking - configure/ networking-deprecated configure/" $OUTPATH/squashfs-root/etc/init/networking-deprecated.conf
    sudo rm $OUTPATH/squashfs-root/etc/init/networking.conf
fi

if [ -f $OUTPATH/squashfs-root/etc/init.d/networking ] ; then
    sudo mv $OUTPATH/squashfs-root/etc/init.d/networking $OUTPATH/squashfs-root/etc/init.d/networking-deprecated
fi
echo Finished changing networking to networking-deprecated
echo Warning, you should reboot later.
