#!/bin/sh
set -e
APPPATH=/home/night/app
WORKPATH=$(cd "$(dirname $0)"; pwd)
OUTPATH=/home/night/out
ISOPATH=/home/box/Workspace/Public/linuxmint-15-cinnamon-dvd-32bit-1-4kernel.iso
LOGNAME="log`date +%Y%m%d`.txt"
ISOOUTPATH=/home/night/isout
if [ -d $OUTPATH/squashfs-root ] ; then
    rm -f -r $OUTPATH/squashfs-root
fi

if [ -d $OUTPATH/initrd_lz ] ; then
    rm -f -r $OUTPATH/initrd_lz
fi

if [ -d $OUTPATH/mymint ] ; then
    rm -f -r $OUTPATH/mymint
fi
cd $WORKPATH
git pull
sudo sh $WORKPATH/release.sh $ISOPATH $APPPATH $OUTPATH $ISOOUTPATH > ~/log/$LOGNAME 2>&1
