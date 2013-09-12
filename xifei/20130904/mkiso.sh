#!/bin/bash
OUTPATH=$PWD/mkiso_out
STARTTIME=`date +%Y%m%d%H%M`
ISONAME="mymint-${STARTTIME}.iso"
KVMIMGNAME="mymint-${STARTTIME}.img"
DESTDIR=~/Public/ISO
MKINITRD=true
MKSQUASHFS=true
STARTKVM=true
USERNAME=xifei

echo "==warning:you should run as root. But be careful!=="

if [ "$USER" != "root" ] ; then
    echo "==error: you are not run as root user, you should excute sudo.=="
    exit
fi

if [ ! -d $OUTPATH ] ; then
    echo "==error: $OUTPATH does not exist. exit.=="
    exit
fi

cd $OUTPATH

if [ ! -e mymint ] ; then
    echo "==error: mymint does not exist. exit.=="
    exit
fi

if [ ! -e mymint/casper ] ; then
    echo "==error: mymint/casper does not exist. exit.=="
    exit
fi

if [ ! -e initrd_lz ] ; then
    echo "==error: initrd_lz does not exist. exit.=="
    exit
fi

if [ ! -e squashfs-root ] ; then
    echo "==error: squashfs-root does not exist. exit.=="
    exit
fi

echo "==mkiso.sh will generate iso file $ISONAME.iso in $OUTPATH.=="

echo "==generate manifest.=="
chroot squashfs-root dpkg-query -W --showformat='${Package} ${Version}\n' > mymint/casper/filesystem.manifest
cp mymint/casper/filesystem.manifest mymint/casper/filesystem.manifest-desktop

if [ "$MKINITRD" == "true" ] ; then
    echo "==make initrd=="
    cd initrd_lz
    find . | cpio --quiet --dereference -o -H newc>./initrd
    gzip initrd
    mv initrd.gz ../mymint/casper/initrd.lz
    cd ..
else
    echo "==make initrd is ignored.=="
fi

if [ "$MKSQUASHFS" == "true" ] ; then
    echo "==make squashfs.=="
    rm -rf mymint/casper/filesystem.squashfs
    mksquashfs squashfs-root mymint/casper/filesystem.squashfs
else
    echo "==make squashfs is ignored.=="
fi

echo "==generic md5sum.=="
cd mymint
find . -type f -print0 | xargs -0 md5sum > md5sum.txt
cd ..

echo  "==making ISO.=="
cd mymint
mkisofs -r -V "mymint" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "${DESTDIR}/$ISONAME" .
echo "==make ISO has finished.=="

cd ${DESTDIR}
chown ${USERNAME}.${USERNAME} $ISONAME
ls -l $ISONAME

if [ "$STARTKVM" == "true" ] ; then
    echo "==prepare for kvm.=="
    touch mymint-${STARTTIME}.sh
    echo """#!/bin/sh
if [ -z \"\$1\" ] ; then
    echo \"you should put a parameter.\"
    exit
fi
SHNAME=\$0
case \$1 in
    \"start\")
        kvm -m 512 -hda $KVMIMGNAME -cdrom $ISONAME
    ;;
    \"delete\")
        name=\${SHNAME%.sh}
        if [ ! -z \$name ] ; then
            rm \$name.*
        fi
    ;;
esac""" > mymint-${STARTTIME}.sh
    chown ${USERNAME}.${USERNAME} mymint-${STARTTIME}.sh

    qemu-img create -f raw $KVMIMGNAME 8G
    kvm -m 512 -hda $KVMIMGNAME -cdrom $ISONAME
    chown ${USERNAME}.${USERNAME} $KVMIMGNAME
fi
