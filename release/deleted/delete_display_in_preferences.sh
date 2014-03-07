#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$1
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo "Delete display in preferences."
myfile=$OUTPATH/squashfs-root/usr/share/applications/cinnamon-display-panel.desktop
if [ -f "$myfile" ] ; then
    rm -f $myfile 
fi

echo "Delete display in preferences successfully!"
