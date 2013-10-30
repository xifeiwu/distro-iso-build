#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param in change icons.
    exit -1
fi

OUTPATH=$1
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo changing: cos4win.exe autorun.inf
if [ -f $OUTPATH/mymint/autorun.inf ] ; then
    rm $OUTPATH/mymint/autorun.inf
fi

if [ -f $OUTPATH/mymint/mint4win.exe ] ; then
    rm $OUTPATH/mymint/mint4win.exe
fi

echo finish changing cos4win.exe autorun.inf
