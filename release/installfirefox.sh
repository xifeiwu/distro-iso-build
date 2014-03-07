#1、安装修改了user-agent为cos-desktop的firefox,把此脚本放在squashfs-root/../路径下,把app目录放在～/app下
#2、安装.xpi汉化firefox

set -e

CHROOTDIR=~/pcos/mkiso_out/squashfs-root
DEBDIR=~/pcos/app
DEBNAME=firefox_25.0+build3-0ubuntu0.13.04.1_i386.deb
XPINAME=langpack-zh-CN@firefox.mozilla.org.xpi

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
    exit -1
fi

mkdir ${CHROOTDIR}/app
cp ${DEBDIR}/${DEBNAME} ${CHROOTDIR}/app

#chroot ${CHROOTDIR} /bin/bash -c "dpkg -r firefox"
chroot ${CHROOTDIR} /bin/bash -c "cd app && dpkg -i -E $DEBNAME"

cp ${DEBDIR}/${XPINAME} ${CHROOTDIR}/app
chroot ${CHROOTDIR} /bin/bash -c "cd app && cp langpack-zh-CN@firefox.mozilla.org.xpi /usr/lib/firefox-addons/extensions/"
#chroot ${CHROOTDIR} /bin/bash -c "echo \"pref('browser.startup.homepage', 'about:blank');\" >> /etc/firefox/syspref.js" 
chroot ${CHROOTDIR} /bin/bash -c "rm -rf app"

echo "firefox installed successful!"
