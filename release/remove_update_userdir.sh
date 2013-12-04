#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$1
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo TODO: remove update user dirs when change language.

if [ -f $OUTPATH/squashfs-root/etc/xdg/autostart/user-dirs-update-gtk.desktop ] ; then
    rm $OUTPATH/squashfs-root/etc/xdg/autostart/user-dirs-update-gtk.desktop
fi

echo finish delete user-dirs-update-gtk.desktop
