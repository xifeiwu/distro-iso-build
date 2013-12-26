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
DRIVERPATCHPATH=$3
KERNELVER=$4

echo The driver $DRIVERTARFILE will be installed into root path: $ROOTPATH

######
# Begin
######
echo Tar jxvf $DRIVERTARFILE
#sudo tar jxvf ../../preapp/s3g-Chrome64x-15.00.02c-CL135330-i386\(1202\).tar.bz2
cd $ROOTPATH/squashfs-root
sudo tar jxvf $DRIVERTARFILE

######
# patch to driver
######
echo patching to driver
sudo cp $DRIVERPATCHPATH -a $ROOTPATH/squashfs-root
cd $ROOTPATH/squashfs-root/S3G-InstallPkg-i386
sudo patch -p1 < ../patches/patch-$4.patch
cd ..

######
# install driver
######
echo Install driver of s3g
sudo chroot $ROOTPATH/squashfs-root /bin/bash -c "cd S3G-InstallPkg-i386 && sh install.sh $4 i386"
sudo chroot $ROOTPATH/squashfs-root /bin/bash -c "cd /etc/init.d && patch -p0 </patches/x11-common.patch"
sudo chroot $ROOTPATH/squashfs-root /bin/bash -c "chmod 777 /etc/init.d/compat-detect && chmod 777 /etc/init.d/detect_card.sh"
sudo chroot $ROOTPATH/squashfs-root /bin/bash -c "rm -rf patches"
sudo chroot $ROOTPATH/squashfs-root /bin/bash -c "update-initramfs -u"

echo Finish installing s3g driver.

######
# End
######
