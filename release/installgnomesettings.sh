#安装gnome-settings
set -e

CHROOTDIR=~/customize/mkiso_out/squashfs-root
DEBDIR=~/app
DEBNAME=gnomesettings.gz

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
cp ${DEBDIR}/${DEBNAME} ${CHROOTDIR}/app

chroot ${CHROOTDIR} /bin/bash -c "echo 'chroot to squashfs-root'"
chroot ${CHROOTDIR} /bin/bash -c "cd app && tar xvf gnomesettings.gz"
#chroot ${CHROOTDIR} /bin/bash -c "apt-get install  -y libdbus-glib-1-dev libglib2.0-dev"
chroot ${CHROOTDIR} /bin/bash -c "dpkg -i  app/gnome-setting/gnome-settings-daemon_3.6.4-0ubuntu8_i386.deb"


chroot ${CHROOTDIR} /bin/bash -c "rm -rf app"

echo "gnomesettings installed successful!"


#sudo chroot ${CHROOTDIR} /bin/bash -c "apt-get install -d language-pack-zh-hans"
#sudo chroot ${CHROOTDIR} /bin/bash -c "touch /etc/default/locale && echo 'LANG=\"zh_CN.UTF-8\"' > /etc/default/locale && echo 'LANGUAGE=\"zh_CN:zh\"' >> /etc/default/locale"

#sudo chroot ${CHROOTDIR} /bin/bash -c "add-apt-repository ppa:fcitx-team/nightly && apt-get update"
#sudo chroot ${CHROOTDIR} /bin/bash -c "apt-get install -d fcitx fcitx-config-gtk fcitx-sunpinyin fcitx-googlepinyin fcitx-module-cloudpinyin  fcitx-sogoupinyin fcitx-table-all im-switch "
