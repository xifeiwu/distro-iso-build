#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$1

echo Change networking to networking-deprecated.
if [ -f $OUTPATH/etc/init/ufw.conf ] ; then
    sed -i "s/ networking)/ networking-deprecated)/" $OUTPATH/etc/init/ufw.conf
fi

if [ -f $OUTPATH/etc/init/network-interface-security.conf ] ; then
    sed -i "s/ networking)/ networking-deprecated)/" $OUTPATH/etc/init/network-interface-security.conf
    sed -i "s/stopped networking /stopped networking-deprecated /" $OUTPATH/etc/init/network-interface-security.conf
fi

if [ -f $OUTPATH/etc/init/networking.conf ] ; then
    cp $OUTPATH/etc/init/networking.conf $OUTPATH/etc/init/networking-deprecated.conf
    sed -i "s/ networking - configure/ networking-deprecated configure/" $OUTPATH/etc/init/networking-deprecated.conf
    rm $OUTPATH/etc/init/networking.conf
fi

if [ -f $OUTPATH/etc/init.d/networking ] ; then
    mv $OUTPATH/etc/init.d/networking $OUTPATH/etc/init.d/networking-deprecated
fi
echo Finished changing networking to networking-deprecated
echo Warning, you should reboot later.
