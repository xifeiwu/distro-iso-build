#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param in change icons.
    exit -1
fi

OUTPATH=$1
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo changing: /usr/share/icons/Mint-X/actions/scalable/system-log-out.svg
cp -f $DISTURBPATH/materials/icn/gnome-logout1.svg $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/scalable/system-log-out.svg
cp -f $DISTURBPATH/materials/icn/gnome-logout1-16.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/16/system-log-out.png
cp -f $DISTURBPATH/materials/icn/gnome-logout1-22.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/22/system-log-out.png
cp -f $DISTURBPATH/materials/icn/gnome-logout1-24.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/24/system-log-out.png
cp -f $DISTURBPATH/materials/icn/gnome-logout1-32.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/32/system-log-out.png
cp -f $DISTURBPATH/materials/icn/gnome-logout1-48.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/48/system-log-out.png

echo changing: /usr/share/icons/Mint-X/apps/scalable/gnome-logout.svg
cp -f $DISTURBPATH/materials/icn/gnome-logout1.svg $OUTPATH/squashfs-root/usr/share/icons/Mint-X/apps/scalable/gnome-logout.svg
cp -f $DISTURBPATH/materials/icn/gnome-logout1-16.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/apps/16/gnome-logout.png
cp -f $DISTURBPATH/materials/icn/gnome-logout1-22.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/apps/22/gnome-logout.png
cp -f $DISTURBPATH/materials/icn/gnome-logout1-24.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/apps/24/gnome-logout.png
cp -f $DISTURBPATH/materials/icn/gnome-logout1-32.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/apps/32/gnome-logout.png
cp -f $DISTURBPATH/materials/icn/gnome-logout1-48.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/apps/48/gnome-logout.png
echo "system log out icon changed!"

echo changing: /usr/share/icons/Mint-X/actions/scalable/system-shutdown.svg
cp -f $DISTURBPATH/materials/icn/gnome-shutdown1.svg $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/scalable/system-shutdown.svg
cp -f $DISTURBPATH/materials/icn/gnome-shutdown1-16.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/16/system-shutdown.png
cp -f $DISTURBPATH/materials/icn/gnome-shutdown1-22.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/22/system-shutdown.png
cp -f $DISTURBPATH/materials/icn/gnome-shutdown1-24.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/24/system-shutdown.png
cp -f $DISTURBPATH/materials/icn/gnome-shutdown1-32.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/32/system-shutdown.png
cp -f $DISTURBPATH/materials/icn/gnome-shutdown1-48.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/48/system-shutdown.png

echo changing: /usr/share/icons/Mint-X/apps/scalable/gnome-shutdown.svg
cp -f $DISTURBPATH/materials/icn/gnome-shutdown1.svg $OUTPATH/squashfs-root/usr/share/icons/Mint-X/apps/scalable/gnome-shutdown.svg
cp -f $DISTURBPATH/materials/icn/gnome-shutdown1-16.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/apps/16/gnome-shutdown.png
cp -f $DISTURBPATH/materials/icn/gnome-shutdown1-22.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/apps/22/gnome-shutdown.png
cp -f $DISTURBPATH/materials/icn/gnome-shutdown1-24.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/apps/24/gnome-shutdown.png
cp -f $DISTURBPATH/materials/icn/gnome-shutdown1-32.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/apps/32/gnome-shutdown.png
cp -f $DISTURBPATH/materials/icn/gnome-shutdown1-48.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/apps/48/gnome-shutdown.png
echo "system shutdown icon changed!"

echo changing: /usr/share/icons/Mint-X/actions/scalable/system-lock-screen.svg
cp -f $DISTURBPATH/materials/icn/system-lock-screen1.svg $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/scalable/system-lock-screen.svg
cp -f $DISTURBPATH/materials/system-lock-screen1-16.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/16/system-lock-screen.png
cp -f $DISTURBPATH/materials/system-lock-screen1-22.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/22/system-lock-screen.png
cp -f $DISTURBPATH/materials/system-lock-screen1-24.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/24/system-lock-screen.png
cp -f $DISTURBPATH/materials/system-lock-screen1-32.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/32/system-lock-screen.png
cp -f $DISTURBPATH/materials/system-lock-screen1-48.png $OUTPATH/squashfs-root/usr/share/icons/Mint-X/actions/48/system-lock-screen.png
echo "system lock screen icon changed!"
