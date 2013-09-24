#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param in change icons.
    exit -1
fi

OUTPATH=$1
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo changing: cos4win.exe autorun.inf
cp -f $DISTURBPATH/wubi/wubi.exe $OUTPATH/mymint/cos4win.exe
cp -f $DISTURBPATH/wubi/autorun.inf $OUTPATH/mymint/autorun.inf
if [ -f $OUTPATH/mymint/mint4win.exe ] ; then
    rm $OUTPATH/mymint/mint4win.exe
fi
echo finish changing cos4win.exe autorun.inf
