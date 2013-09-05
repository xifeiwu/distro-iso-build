#安装wps-office,把此脚本放在squashfs-root/../路径下,把app目录放在～/app下
CHROOTDIR=~/customize/squashfs-root
DEBDIR=~/app
DEBNAME=wps-office_8.1.0.3724~b1p2_i386.deb

if [ ! -e "${CHROOTDIR}" ]; then
    echo "squashfs-root not found"
    exit
fi

mkdir ${CHROOTDIR}/app
sudo cp ${DEBDIR}/${DEBNAME} ${CHROOTDIR}/app

sudo chroot ${CHROOTDIR} /bin/bash -c "cd app && dpkg -i wps-office_8.1.0.3724~b1p2_i386.deb && apt-get remove -y --purge libreoffice-*"
sudo chroot ${CHROOTDIR} /bin/bash -c "rm -rf app"
#sudo cp ~/文档/* ${CHROOTDIR}

echo "wps-office installed successful!"
