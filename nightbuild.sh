#!/bin/sh
APPPATH=/home/box/Workspace/Public/app
WORKPATH=$(cd "$(dirname $0)"; pwd)
OUTPATH=/home/night/out
ISOPATH=/home/box/Workspace/Public/linuxmint-15-cinnamon-dvd-32bit-1-4kernel-2.iso
LOGNAME="log`date +%Y%m%d%H%M`.txt"
MAILNAME="[IBP-COS-buildlog]`date +%Y%m%d%H%M`"
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
cat ~/log/$LOGNAME | mutt -s $MAILNAME wangbo@iscas.ac.cn jianmin@nfs.iscas.ac.cn xifei@nfs.iscas.ac.cn wangfeng@nfs.iscas.ac.cn wangyu@nfs.iscas.ac.cn yuanzhe@iscas.ac.cn
