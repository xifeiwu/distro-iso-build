#安装google-chrome,把此脚本放在squashfs-root/../路径下,把app目录放在～/app下
CHROOTDIR=~/customize/mkiso_out/squashfs-root
DEBDIR=~/app
DEBNAME=google-chrome-stable_current_i386.deb

if [ ! -e "${CHROOTDIR}" ]; then
    echo "squashfs-root not found"
    exit
fi

mkdir ${CHROOTDIR}/app
sudo cp ${DEBDIR}/${DEBNAME} ${CHROOTDIR}/app

sudo chroot ${CHROOTDIR} /bin/bash -c "cd app && dpkg -i google-chrome-stable_current_i386.deb"
sudo chroot ${CHROOTDIR} /bin/bash -c "rm -rf app"
#sudo chroot ${CHROOTDIR} /bin/bash -c "apt-get remove -y firefox"


echo "google-chrome installed successful!"
