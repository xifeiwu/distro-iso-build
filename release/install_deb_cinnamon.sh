#~bin/sh
set -e

DISTURBPATH=$(cd "$(dirname $0)"; pwd)
SOURCEPATH=$(cd $DISTURBPATH/../../source/cinnamon-src/cinnamon; pwd)
DIRNAME=cinnamon-1.8.8+olivia

echo "build and install cinnamon package"

if [ -z "$SOURCEPATH" ] ; then
    echo error: No chrootdir setting at first param.
    exit -1
fi


if [ -z "$1" ] ; then
    echo error: No chrootdir setting at first param.
    exit -1
fi

CHROOTDIR=$1/squashfs-root

if [ ! -e "${CHROOTDIR}" ]; then
    echo "squashfs-root not found"
    exit -1
fi

# copy source code
mkdir ${CHROOTDIR}/cinnamon
echo "start to copy cinnamon, just wait fot a minute"
cp -rf ${SOURCEPATH}/${DIRNAME} ${CHROOTDIR}/cinnamon

# install build depends
echo install build-depends
apt-get -y install debhelper dh-autoreconf python-dev gnome-pkg-tools intltool libgjs-dev gvfs-backends gobject-introspection gir1.2-json-1.0 gnome-bluetooth gnome-common gsettings-desktop-schemas-dev libcaribou-dev libcroco3-dev libdbus-glib-1-dev libgconf2-dev libgirepository1.0-dev libglib2.0-dev libglib2.0-bin libgnome-bluetooth-dev libgnome-desktop-3-dev libgnome-keyring-dev libgnome-menu-3-dev libgstreamer0.10-dev libgtk-3-dev libgudev-1.0-dev libnm-glib-dev libstartup-notification0-dev libmuffin-dev librsvg2-dev libsoup2.4-dev libwnck-dev libclutter-1.0-dev libxfixes-dev libxss-dev libpulse-dev libcanberra-dev libpolkit-agent-1-dev libjson-glib-dev 
echo build-depends is already installed

# build an install deb
cd ${CHROOTDIR}/cinnamon/cinnamon-1.8.8+olivia && dpkg-buildpackage  -uc -us

chroot ${CHROOTDIR} /bin/bash -c "cd cinnamon && dpkg -i -E cinnamon-common_1.8.8+iceblue_all.deb"
echo "cinnamon-common installed successful!"

chroot ${CHROOTDIR} /bin/bash -c "cd cinnamon && dpkg -i -E cinnamon_1.8.8+iceblue_i386.deb"
echo "cinnamon installed successful!"

chroot ${CHROOTDIR} /bin/bash -c "rm -rf cinnamon"

echo "install_deb_cinnamon.sh execute successful!"
