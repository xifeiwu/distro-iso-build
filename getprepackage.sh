#~/bin/sh
set -e

if [ $# -lt 1 ] ; then
    echo You should execute this script with three param at least as follow:
    echo sh $0 PREAPPPATH
    exit -1
fi

if [ -e $1 ] ; then
    if [ ! -d $1 ] ; then
        echo You should make sure the preapppath $1 is a dir
        exit -1
    fi
else
    mkdir $1
fi

ScriptPATH=$(cd "$(dirname $0)"; pwd)
PREAPPPATH=$(cd $1; pwd)

echo The prebuilt deb package will be downloaded in $PREAPPPATH

######
# Begin
######
echo
echo Copying prebuilt deb package
rsync -av --delete --progress box@192.168.162.142:/home/box/Workspace/Public/app/ $PREAPPPATH
echo Finish copying prebuilt deb package
######
# End
######
