#安装google-chrome,把此脚本放在squashfs-root/../路径下,把app目录放在～/app下
CHROOTDIR=~/customize/mkiso_out/squashfs-root
DEBDIR=~/app
DEBNAME=WineQQ2012-20121221-Longene.deb

if [ ! -e "${CHROOTDIR}" ]; then
    echo "squashfs-root not found"
    exit
fi

mkdir ${CHROOTDIR}/app
sudo cp ${DEBDIR}/${DEBNAME} ${CHROOTDIR}/app


sudo chroot ${CHROOTDIR} /bin/bash -c "cd app && dpkg -i WineQQ2012-20121221-Longene.deb"
sudo chroot ${CHROOTDIR} /bin/bash -c "rm -rf app"


echo "WineQQ installed successful!"
