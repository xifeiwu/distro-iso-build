#本脚本所做工作：编译内核，在squashfs中安装新内核，替换livecd内核

MKISOOUTDIR=~/customize/mkiso_out
CHROOTDIR=~/customize/mkiso_out/squashfs-root
KERNELSOURCEDIR=~/kernel/sources

if [ -z "$1" ] ; then
    echo error: No mkiso_out setting at first param.
    exit -1
fi
if [ -z "$2" ] ; then
    echo error: No chrootdir setting at first param.
    exit -1
fi
if [ -z "$3" ] ; then
    echo error: No kernel sources setting at first param.
    exit -1
fi

MKISOOUTDIR=$1
CHROOTDIR=$2
KERNELSOURCEDIR=$3


if [ ! -e "${CHROOTDIR}" ]; then
    echo "squashfs-root not found"
    exit
fi


sudo cp -r ${KERNELSOURCEDIR} $CHROOTDIR
sudo chroot ${CHROOTDIR} /bin/bash -c "cd sources && sh kernel-build.sh"

sudo chroot ${CHROOTDIR} /bin/bash -c "cd sources/kernel-build && dpkg -i linux-image*.deb"
sudo chroot ${CHROOTDIR} /bin/bash -c "cd sources/kernel-build && dpkg -i linux-headers*.deb"
sudo chroot ${CHROOTDIR} /bin/bash -c "cd /boot && rm -f abi-3.8.0-19-generic config-3.8.0-19-generic initrd.img-3.8.0-19-generic System.map-3.8.0-19-generic vmlinuz-3.8.0-19-generic"
sudo chroot ${CHROOTDIR} /bin/bash -c "update-grub && rm -rf sources"

sudo chroot ${CHROOTDIR} /bin/bash -c "apt-get install -y unionfs-fuse"
sudo chroot ${CHROOTDIR} /bin/bash -c "mkinitramfs -o /initrd.gz 3.8.0-cos-v0.5-i686"


sudo cp ${CHROOTDIR}/initrd.gz ${CHROOTDIR}/boot/initrd.lz
sudo cp ${CHROOTDIR}/initrd.gz ${MKISOOUTDIR}/mycos/casper/initrd.lz
sudo rm -f ${CHROOTDIR}/initrd.gz
sudo cp ${CHROOTDIR}/boot/vmlinuz-3.8.0-cos-v0.5-i686 ${MKISOOUTDIR}/mycos/casper/vmlinuz



cd ${MKISOOUTDIR}
if [ ! -e initrd_lz ] ; then
    echo lzma initrd.lz
    mkdir initrd_lz
    cp mycos/casper/initrd.lz initrd_lz/initrd.lz
    echo warning: now, it is supported the format of initrd.lz is gzip, not lzma. If it is lzma, you should change it.
    cd initrd_lz
    mv initrd.lz initrd.gz
    gunzip initrd.gz
    cpio -id<./initrd
    cd ..
else
    echo warning: initrd_lz has exist, it is expected initrd.lz has been decompressed normally.
fi



echo " New kernel installed successful!"

