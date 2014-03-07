#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

run_patch(){
set +e
patch --dry-run -N $*
ERROR=$?
if [ $ERROR -eq 0 ] ; then
    patch -t -s -N $*
else
    patch -t -s -R -N $*
    patch -t -s -N $*
fi
set -e
}

OUTPATH=$(cd $1; pwd)
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo "Reconfig start menu..."

applicationPath=$OUTPATH/squashfs-root/usr/share/applications
if [ ! -x "$applicationPath" ] ; then
    echo "The applications directory does not exist!"
    exit -1
fi
cd $OUTPATH/squashfs-root/usr/share/applications
rm -f aptoncd.desktop
cp $DISTURBPATH/tmpfiles/applications/baobab.desktop .
cp $DISTURBPATH/tmpfiles/applications/bluetooth-sendto.desktop .
cp $DISTURBPATH/tmpfiles/applications/bluetooth-wizard.desktop .
cp $DISTURBPATH/tmpfiles/applications/caribou.desktop .
cp $DISTURBPATH/tmpfiles/applications/cinnamon-control-center.desktop .
cp $DISTURBPATH/tmpfiles/applications/cinnamon-network-panel.desktop .
cp $DISTURBPATH/tmpfiles/applications/cinnamon-settings.desktop .
cp $DISTURBPATH/tmpfiles/applications/cinnamon-sound-nua-panel.desktop .
rm -f cinnamon-universal-access-panel.desktop
cp $DISTURBPATH/tmpfiles/applications/cinnamon-user-accounts-panel.desktop .
cp $DISTURBPATH/tmpfiles/applications/evince.desktop .
rm -f fcitx-config-gtk3.desktop
rm -f fcitx-configtool.desktop
cp $DISTURBPATH/tmpfiles/applications/fcitx.desktop .
rm -f file-roller.desktop
cp $DISTURBPATH/tmpfiles/applications/firefox.desktop .
cp $DISTURBPATH/tmpfiles/applications/gcalctool.desktop .
cp $DISTURBPATH/tmpfiles/applications/gcr-prompter.desktop .
rm -f gdebi.desktop
cp $DISTURBPATH/tmpfiles/applications/gedit.desktop .
cp $DISTURBPATH/tmpfiles/applications/gnome-disk-image-mounter.desktop .
cp $DISTURBPATH/tmpfiles/applications/gnome-disks.desktop .
rm -f gnome-font-viewer.desktop
rm -f gnome-power-statistics.desktop
cp $DISTURBPATH/tmpfiles/applications/gnome-screenshot.desktop .
cp $DISTURBPATH/tmpfiles/applications/gnome-system-log.desktop .
cp $DISTURBPATH/tmpfiles/applications/gnome-system-monitor.desktop .
cp $DISTURBPATH/tmpfiles/applications/gnome-system-monitor-kde.desktop .
cp $DISTURBPATH/tmpfiles/applications/gnome-terminal.desktop .
rm -f gnome-user-share-properties.desktop
cp $DISTURBPATH/tmpfiles/applications/gparted.desktop .
cp $DISTURBPATH/tmpfiles/applications/gthumb.desktop .
rm -f gucharmap.desktop
cp $DISTURBPATH/tmpfiles/applications/gufw.desktop .
rm -f im-config.desktop
rm -f itweb-settings.desktop
cp $DISTURBPATH/tmpfiles/applications/mintBackup.desktop .
cp $DISTURBPATH/tmpfiles/applications/mintBackup_mime.desktop .
cp $DISTURBPATH/tmpfiles/applications/mintdrivers.desktop .
cp $DISTURBPATH/tmpfiles/applications/mintInstall.desktop .
cp $DISTURBPATH/tmpfiles/applications/mintInstall_kde.desktop .
cp $DISTURBPATH/tmpfiles/applications/mintInstall_mime.desktop .
rm -f mintNanny.desktop
cp $DISTURBPATH/tmpfiles/applications/mintsources.desktop .
rm -f mintstick.desktop
rm -f mintstick-kde.desktop
cp $DISTURBPATH/tmpfiles/applications/mintUpdate.desktop .
rm -f mintWelcome.desktop
cp $DISTURBPATH/tmpfiles/applications/mono-runtime.desktop .
cp $DISTURBPATH/tmpfiles/applications/mono-runtime-terminal.desktop .
rm -f ndisgtk.desktop
cp $DISTURBPATH/tmpfiles/applications/ndisgtk-kde.desktop .
cp $DISTURBPATH/tmpfiles/applications/nemo-autorun-software.desktop .
cp $DISTURBPATH/tmpfiles/applications/nemo.desktop .
cp $DISTURBPATH/tmpfiles/applications/nm-applet.desktop .
cp $DISTURBPATH/tmpfiles/applications/nm-connection-editor.desktop .
rm -f openjdk-7-policytool.desktop
rm -f seahorse.desktop
cp $DISTURBPATH/tmpfiles/applications/session-properties.desktop .
rm -f simple-scan.desktop
cp $DISTURBPATH/tmpfiles/applications/synaptic.desktop .
rm -f synaptic-kde.desktop
cp $DISTURBPATH/tmpfiles/applications/system-config-printer.desktop .
cp $DISTURBPATH/tmpfiles/applications/tomboy.desktop .
cp $DISTURBPATH/tmpfiles/applications/totem.desktop .
cp $DISTURBPATH/tmpfiles/applications/ubiquity-gtkui.desktop .
rm -f upload-manager.desktop
cp $DISTURBPATH/tmpfiles/applications/vino-preferences.desktop .
rm -f xchat.desktop
cp $DISTURBPATH/tmpfiles/applications/yelp.desktop .
echo "Patch applications directory successfully!"

mdmApplicationsPath=$OUTPATH/squashfs-root/usr/share/mdm/applications
if [ ! -x "$mdmApplicationsPath" ] ; then
    echo "The mdm applications directory does not exist!"
    exit -1
fi
cd $OUTPATH/squashfs-root/usr/share/mdm/applications
rm -f mdmflexiserver.desktop
cp  $DISTURBPATH/tmpfiles/mdm/applications/mdmsetup.desktop .
echo "Patch mdm applications directory successfully!"

echo "Reconfig start menu successfully!"

