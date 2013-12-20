#~/bin/sh
set -e
 
if [ $# -lt 2 ] ; then
    echo You should execute this script with two params at least as follow:
    echo sh $0 ROOTPATH DRIVERTARFILE
    exit -1
fi

if [ ! -d $1 ] ; then
    echo You should make sure the root path $1 is correct.
    exit -1
fi

if [ ! -f $2 ] ; then
    echo You should make sure the driver tar file $2 exist.
    exit -1
fi

ScriptPATH=$(cd "$(dirname $0)"; pwd)
ROOTPATH=$(cd $1; pwd)
DRIVERTARFILE=$2

echo The driver $DRIVERTARFILE will be installed into root path: $ROOTPATH

######
# Begin
######
echo Tar jxvf $DRIVERTARFILE
#sudo tar jxvf ../../preapp/s3g-Chrome64x-15.00.02c-CL135330-i386\(1202\).tar.bz2
cd $ROOTPATH
sudo tar jxvf $DRIVERTARFILE

echo Install driver of s3g
sudo chroot $ROOTPATH /bin/bash -c "cd S3G-InstallPkg-i386 && sh install.sh"
sudo chroot $ROOTPATH /bin/bash -c "update-initramfs -u"

echo Finish installing s3g driver.

######
# End
######
