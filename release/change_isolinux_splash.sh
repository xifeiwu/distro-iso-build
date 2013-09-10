#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$1
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo change mymint/isolinux/splash.png
cp $DISTURBPATH/isolinux/splash.jpg $OUTPATH/mymint/isolinux/splash.jpg
