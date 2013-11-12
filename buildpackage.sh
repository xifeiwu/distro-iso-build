#~/bin/sh
set -e

if [ $# -lt 1 ] ; then
    echo You should execute this script with three param at least as follow:
    echo sh $0 APPOUTPATH
    exit -1
fi

if [ -e $1 ] ; then
    if [ ! -d $1 ] ; then
        echo You should make sure the outpath $1 is a dir
        exit -1
    fi
else
    mkdir $1
fi

ScriptPATH=$(cd "$(dirname $0)"; pwd)
SRCDesktopPATH=$(cd "$(dirname $0)/../desktop"; pwd)
SRCCOSPATH=$(cd "$(dirname $0)/../cos"; pwd)

APPOUTPATH=$(cd $1; pwd)

echo The self deb package will be generated in $APPOUTPATH
echo The deb source dir:
echo 1. $SRCDesktopPATH
echo 2. $SRCCOSPATH

######
# Begin
######
echo
echo Building deb package
for dir in `ls $SRCDesktopPATH | sort`
do
   if [ -d $SRCDesktopPATH/$dir ] ; then
     echo 
     echo Building $dir ...
     cd $SRCDesktopPATH/$dir
     dpkg-buildpackage -tc
     echo Finish building $dir.
   fi
done 
for dir in `ls $SRCCOSPATH | sort`
do
   if [ -d $SRCCOSPATH/$dir ] ; then
     echo 
     echo Building $dir ...
     cd $SRCCOSPATH/$dir

######
# End
######
