#安装wps-office和wps需要的字体，该字体版权属于微软,把此脚本放在squashfs-root/../路径下,把app目录放在～/app下
CHROOTDIR=~/customize/squashfs-root
DEBDIR=~/app
DEBNAME=wps-office_8.1.0.3724~b1p2_i386.deb
DEBNAME2=wps_symbol_fonts.tar.gz

if [ ! -e "${CHROOTDIR}" ]; then
    echo "squashfs-root not found"
    exit
fi

mkdir ${CHROOTDIR}/app
sudo cp ${DEBDIR}/${DEBNAME} ${CHROOTDIR}/app
sudo cp ${DEBDIR}/${DEBNAME2} ${CHROOTDIR}/app

sudo chroot ${CHROOTDIR} /bin/bash -c "cd app && dpkg -i wps-office_8.1.0.3724~b1p2_i386.deb && apt-get remove -y --purge libreoffice-*"
#安装wps所需字体，该字体版权属于微软
sudo chroot ${CHROOTDIR} /bin/bash -c "cd app && tar xvf wps_symbol_fonts.tar.gz && cp wps_symbol_fonts/* /usr/share/fonts/wps-office"
sudo chroot ${CHROOTDIR} /bin/bash -c "rm -rf app"
#sudo cp ~/文档/* ${CHROOTDIR}

echo "Wps-office and wps-fonts installed successful!"
