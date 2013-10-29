#设置安装COS启动界面，加入进度条
set -e

CHROOTDIR=~/customize/mkiso_out/squashfs-root
DEBDIR=~/app
DEBNAME=COS-Desktop-theme.tar.gz

if [ -z "$1" ] ; then
    echo error: No chrootdir setting at first param.
    exit -1
fi

if [ -z "$2" ] ; then
    echo error: No deb dir setting at second param.
    exit -1
fi

CHROOTDIR=$1/squashfs-root
DEBDIR=$2

if [ ! -e "${CHROOTDIR}" ]; then
    echo "squashfs-root not found"
    exit
fi

mkdir ${CHROOTDIR}/app
sudo cp ${DEBDIR}/${DEBNAME} ${CHROOTDIR}/app

sudo chroot ${CHROOTDIR} /bin/bash -c "echo 'chroot to squashfs-root'"
sudo chroot ${CHROOTDIR} /bin/bash -c "cd app && tar xvf COS-Desktop-theme.tar.gz && chmod 777 -R COS-Desktop-theme && cp -a COS-Desktop-theme /lib/plymouth/themes/"
sudo chroot ${CHROOTDIR} /bin/bash -c "update-alternatives --install /lib/plymouth/themes/default.plymouth default.plymouth /lib/plymouth/themes/COS-Desktop-theme/COS-Desktop-theme.plymouth 100"
#sudo chroot ${CHROOTDIR} /bin/bash -c "cd app && rm -f /lib/plymouth/themes/default.plymouth && cp COS-Desktop-theme/default.plymouth /lib/plymouth/themes/default.plymouth"
#sudo chroot ${CHROOTDIR} /bin/bash -c "cd /lib/plymouth/themes && rm -rf  mint-logo  mint-text  no-logo  no-text  text.plymouth  ubuntu-text"
#sudo chroot ${CHROOTDIR} /bin/bash -c "ln -sf /lib/plymouth/themes/COS-Desktop-theme/COS-Desktop-theme.plymouth /etc/alternatives/default.plymouth"
sudo chroot ${CHROOTDIR} /bin/bash -c "update-alternatives --remove  default.plymouth /lib/plymouth/themes/mint-logo/mint-logo.plymouth"
sudo chroot ${CHROOTDIR} /bin/bash -c "update-alternatives --remove  default.plymouth /lib/plymouth/themes/no-logo/no-logo.plymouth"
sudo chroot ${CHROOTDIR} /bin/bash -c "update-alternatives --config default.plymouth"

sudo chroot ${CHROOTDIR} /bin/bash -c "rm -rf app"
sudo chroot ${CHROOTDIR} /bin/bash -c "rm -rf /home/v1"
sudo chroot ${CHROOTDIR} /bin/bash -c "update-initramfs -u"
sudo chroot ${CHROOTDIR} /bin/bash -c "mkinitramfs -o /initrd.gz 3.8.0-19-generic"

sudo cp ${CHROOTDIR}/initrd.gz ${CHROOTDIR}/boot/initrd.lz
sudo mv ${CHROOTDIR}/initrd.gz ${CHROOTDIR}/../mymint/casper/initrd.lz


echo "COS theme installed successful!"
