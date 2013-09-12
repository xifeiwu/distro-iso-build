#设置默认语言为中文简体，安装sogou中文输入法,把此脚本放在squashfs-root/../路径下,把app目录放在～/app下
CHROOTDIR=~/customize/mkiso_out/squashfs-root
DEBDIR=~/app
DEBNAME=vim-7.3.547.tar.gz

if [ ! -e "${CHROOTDIR}" ]; then
    echo "squashfs-root not found"
    exit
fi

mkdir ${CHROOTDIR}/app
sudo cp ${DEBDIR}/${DEBNAME} ${CHROOTDIR}/app

sudo chroot ${CHROOTDIR} /bin/bash -c "echo 'chroot to squashfs-root'"
sudo chroot ${CHROOTDIR} /bin/bash -c "cd app && tar xvf vim-7.3.547.tar.gz"
sudo chroot ${CHROOTDIR} /bin/bash -c "dpkg -i app/vim-7.3.547/*.deb"


sudo chroot ${CHROOTDIR} /bin/bash -c "rm -rf app"

echo "Vim installed successful!"


#sudo chroot ${CHROOTDIR} /bin/bash -c "apt-get install -d language-pack-zh-hans"
#sudo chroot ${CHROOTDIR} /bin/bash -c "touch /etc/default/locale && echo 'LANG=\"zh_CN.UTF-8\"' > /etc/default/locale && echo 'LANGUAGE=\"zh_CN:zh\"' >> /etc/default/locale"

#sudo chroot ${CHROOTDIR} /bin/bash -c "add-apt-repository ppa:fcitx-team/nightly && apt-get update"
#sudo chroot ${CHROOTDIR} /bin/bash -c "apt-get install -d fcitx fcitx-config-gtk fcitx-sunpinyin fcitx-googlepinyin fcitx-module-cloudpinyin  fcitx-sogoupinyin fcitx-table-all im-switch "
