#~/bin/sh
set -e
 
if [ $# -lt 4 ] ; then
    echo You should execute this script with four params at least as follow:
    echo sh $0 WORKPATH PREAPPPATH ISOADDRESS PREAPPADDRESS
    exit -1
fi

if [ -e $1 ] ; then
    if [ ! -d $1 ] ; then
        echo You should make sure the work path $1 is a dir
        exit -1
    fi
else
    mkdir $1
fi

if [ -e $2 ] ; then
    if [ ! -d $2 ] ; then
        echo You should make sure the preapp path $2 is a dir
        exit -1
    fi
else
    mkdir $2
fi

ScriptPATH=$(cd "$(dirname $0)"; pwd)
WORKPATH=$(cd $1; pwd)
PREAPPPATH=$WORKPATH/preapp
ISOADDRESS=$3
PREAPPADDRESS=$4
if [ -e $PREAPPPATH ] ; then
    if [ ! -d $PREAPPPATH ] ; then
        echo You should make sure the preapppath $PREAPPPATH is a dir
        exit -1
    fi
else
    mkdir $PREAPPPATH
fi

echo The raw iso will be downloaded in $WORKPATH
echo The prebuilt deb package will be downloaded in $PREAPPPATH

######
# Begin
######
echo
echo Copying raw squashfs
echo 
#rsync -av box@192.168.162.142:/home/box/Workspace/Public/linuxmint-15-cinnamon-dvd-32bit-1-4kernel-3.iso $WORKPATH
rsync -av --progress $3 $WORKPATH
echo 
echo Finish copying raw iso

echo
echo Copying prebuilt deb package
echo 
#rsync -av --delete --progress box@192.168.162.142:/home/box/Workspace/Public/app/ $PREAPPPATH
rsync -av --delete --progress $4 $PREAPPPATH
echo
echo Finish copying prebuilt deb package

######
# End
######
